/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPServices
import Foundation

class AssuranceSession {
    let RECONNECT_TIMEOUT = 5
    let assuranceExtension: Assurance
    var pinCodeScreen: SessionAuthorizingUI?
    let outboundQueue: ThreadSafeQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
    let inboundQueue: ThreadSafeQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
    let inboundSource: DispatchSourceUserDataAdd = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.global(qos: .default))
    let outboundSource: DispatchSourceUserDataAdd = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.global(qos: .default))
    let pluginHub: PluginHub = PluginHub()

    lazy var socket: SocketConnectable  = {
        return WebViewSocket(withDelegate: self)
    }()

    lazy var statusUI: iOSStatusUI  = {
        iOSStatusUI.init(withSession: self)
    }()

    // MARK: - boolean flags

    /// indicates if the session is currently attempting to reconnect. This flag is set when the session disconnects due to some retry-able reason,
    /// This flag is reset when the session is connected or successfully terminated
    var isAttemptingToReconnect: Bool = false

    /// indicates if Assurance SDK can start forwarding events to the session. This flag is set when a command `startForwarding` is received from the socket.
    var canStartForwarding: Bool = false

    /// true indicates Assurance SDK has timeout and shutdown after non-reception of deep link URL because of which it  has cleared all the queued initial SDK events from memory.
    var didClearBootEvent: Bool = false

    /// Initializer with instance of  `Assurance` extension
    init(_ assuranceExtension: Assurance) {
        self.assuranceExtension = assuranceExtension
        handleInBoundEvents()
        handleOutBoundEvents()
        registerInternalPlugins()
    }

    ///
    /// Called this method to start an Assurance session.
    /// If the session was already connected, It will resume the connection.
    /// Otherwise PinCode screen is presented for establishing a new connection.
    ///
    func startSession() {
        if socket.socketState == .open || socket.socketState == .connecting {
            Log.debug(label: AssuranceConstants.LOG_TAG, "There is already an ongoing Assurance session. Ignoring to start new session.")
            return
        }

        // if there is a socket URL already connected in the previous session, reuse it.
        if let socketURL = assuranceExtension.connectedWebSocketURL {
            self.statusUI.display()
            socket.connect(withUrl: URL(string: socketURL)!)
            return
        }

        // if there were no previous connected URL then start a new session
        beginNewSession()
    }

    /// Called when a valid assurance deep link url is received from the startSession API
    /// Calling this method will attempt to display the pinCode screen for session authentication
    ///
    /// Thread : Listener thread from EventHub
    func beginNewSession() {
        let pinCodeScreen = iOSPinCodeScreen.init(withExtension: assuranceExtension)
        self.pinCodeScreen = pinCodeScreen

        // invoke the pinpad screen and create a socketURL with the pincode and other essential parameters
        pinCodeScreen.show(callback: { [weak self]  socketURL, error in
            if let error = error {
                self?.handleConnectionError(error: error, closeCode: nil)
                return
            }

            guard let socketURL = socketURL else {
                Log.debug(label: AssuranceConstants.LOG_TAG, "SocketURL to connect to session is empty. Ignoring to start Assurance session.")
                return
            }

            // Thread : main thread (this callback is called from `overrideUrlLoad` method of WKWebView)
            Log.debug(label: AssuranceConstants.LOG_TAG, "Attempting to make a socket connection with URL : \(socketURL)")
            self?.socket.connect(withUrl: socketURL)
            pinCodeScreen.connectionInitialized()
        })
    }

    ///
    /// Terminates the ongoing Assurance session.
    ///
    func terminateSession() {
        socket.disconnect()
        clearSessionData()
    }

    ///
    /// Sends the `AssuranceEvent` to the connected session.
    /// - Parameter assuranceEvent - an `AssuranceEvent` to be forwarded
    ///
    func sendEvent(_ assuranceEvent: AssuranceEvent) {
        outboundQueue.enqueue(newElement: assuranceEvent)
        outboundSource.add(data: 1)
    }

    func handleConnectionError(error: AssuranceConnectionError, closeCode: Int?) {
        // if the pinCode screen is still being displayed. Then use the same webView to display error
        Log.debug(label: AssuranceConstants.LOG_TAG, "Socket disconnected with error :\(error.info.name) \n description : \(error.info.description) \n close code: \(closeCode ?? -1)")
        if pinCodeScreen?.isDisplayed == true {
            pinCodeScreen?.connectionFailedWithError(error)
        } else {
            let errorView = ErrorView.init(AssuranceConnectionError.clientError)
            errorView.display()
        }

        if let closeCode = closeCode {
            pluginHub.notifyPluginsOnDisconnect(withCloseCode: closeCode)
        }

        // since we don't give retry option for these errors and UI will be dismissed anyway, hence notify plugins for onSessionTerminated
        if !error.info.shouldRetry {
            clearSessionData()
            statusUI.remove()
            pluginHub.notifyPluginsOnSessionTerminated()
        }
    }

    ///
    /// Adds the log to Assurance Status UI.
    /// - Parameters:
    ///     - message: `String` log message
    ///     - visibility: an `AssuranceClientLogVisibility` determining the importance of the log message
    ///
    func addClientLog(_ message: String, visibility: AssuranceClientLogVisibility) {
        statusUI.addClientLog(message, visibility: visibility)
    }

    ///
    /// Clears the queued SDK events from memory. Call this method once Assurance shut down timer is triggered.
    ///
    func clearQueueEvents() {
        inboundQueue.clear()
        outboundQueue.clear()
        didClearBootEvent = true
    }

    ///
    /// Clears all the data related to the current Assurance Session.
    /// Call this method when user terminates the Assurance session or when non-recoverable socket error occurs.
    ///
    func clearSessionData() {
        assuranceExtension.clearState()
        canStartForwarding = false
        pluginHub.notifyPluginsOnSessionTerminated()
        assuranceExtension.sessionId = nil
        assuranceExtension.connectedWebSocketURL = nil
        assuranceExtension.environment = AssuranceConstants.DEFAULT_ENVIRONMENT
        pinCodeScreen = nil
    }

    // MARK: - Private methods

    ///
    /// Registers all the available internal plugin with PluginHub.
    ///
    private func registerInternalPlugins() {
        pluginHub.registerPlugin(PluginFakeEvent(), toSession: self)
        pluginHub.registerPlugin(PluginConfigModify(), toSession: self)
        pluginHub.registerPlugin(PluginScreenshot(), toSession: self)
        pluginHub.registerPlugin(PluginLogForwarder(), toSession: self)
    }

}
