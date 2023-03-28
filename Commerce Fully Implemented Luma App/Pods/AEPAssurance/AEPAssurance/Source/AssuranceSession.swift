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
    let stateManager: AssuranceStateManager
    var sessionDetails: AssuranceSessionDetails
    let presentationDelegate: AssurancePresentationDelegate
    let connectionDelegate: AssuranceConnectionDelegate
    let sessionOrchestrator: AssuranceSessionOrchestrator
    let outboundQueue: ThreadSafeQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
    let inboundQueue: ThreadSafeQueue = ThreadSafeQueue<AssuranceEvent>(withLimit: 200)
    let inboundSource: DispatchSourceUserDataAdd = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.global(qos: .default))
    let outboundSource: DispatchSourceUserDataAdd = DispatchSource.makeUserDataAddSource(queue: DispatchQueue.global(qos: .default))
    let pluginHub: PluginHub = PluginHub()

    #if DEBUG
    var statusPresentation: AssuranceStatusPresentation
    #else
    let statusPresentation: AssuranceStatusPresentation
    #endif
    lazy var socket: SocketConnectable  = {
        return WebViewSocket(withDelegate: self)
    }()

    // MARK: - boolean flags

    /// indicates if the session is currently attempting to reconnect. This flag is set when the session disconnects due to some retry-able reason,
    /// This flag is reset when the session is connected or successfully terminated
    var isAttemptingToReconnect: Bool = false

    /// indicates if Assurance SDK can start forwarding events to the session. This flag is set when a command `startForwarding` is received from the socket.
    var canStartForwarding: Bool = false

    /// Initializer
    /// - Parameters:
    ///    - sessionDetails: A valid `AssuranceSessionDetails` instance that contains at least sessionId and clientId to start a session
    ///    - stateManager: `AssuranceStateManager` instance responsible for managing Assurance shared state and fetching other extension shared states
    ///    - sessionOrchestrator: an orchestrating component that manages this session
    ///    - outboundEvents: events that are queued before this session is initiated
    init(sessionDetails: AssuranceSessionDetails, stateManager: AssuranceStateManager, sessionOrchestrator: AssuranceSessionOrchestrator, outboundEvents: ThreadSafeArray<AssuranceEvent>?) {
        self.sessionDetails = sessionDetails
        self.stateManager = stateManager
        self.sessionOrchestrator = sessionOrchestrator
        self.presentationDelegate = sessionOrchestrator
        self.connectionDelegate = sessionOrchestrator
        statusPresentation = AssuranceStatusPresentation(with: iOSStatusUI(presentationDelegate: presentationDelegate))
        handleInBoundEvents()
        handleOutBoundEvents()
        registerInternalPlugins()

        /// Queue the outboundEvents to outboundQueue
        if let outboundEvents = outboundEvents {
            for eachEvent in outboundEvents.shallowCopy {
                outboundQueue.enqueue(newElement: eachEvent)
            }
        }
    }
    
    /// Starts an assurance session connection with the provided sessionDetails.
    ///
    /// If the sessionDetails is not authenticated (doesn't have pin or orgId), it triggers the presentation to launch the pinCode screen
    /// If the sessionDetails is already authenticated, then connects directly without pin prompt.
    func startSession() {
        if socket.socketState == .open || socket.socketState == .connecting {
            Log.debug(label: AssuranceConstants.LOG_TAG, "There is already an ongoing Assurance session. Ignoring to start new session.")
            return
        }

        switch sessionDetails.getAuthenticatedSocketURL() {
        case .success(let url):
            // if the URL is already authenticated with Pin and OrgId,
            // then immediately make the socket connection
            socket.connect(withUrl: url)
        case .failure:
            // if the URL is not authenticated, then bring up the pinpad screen
            presentationDelegate.initializePinScreenFlow()
        }
    }

    ///
    /// Terminates the ongoing Assurance session.
    ///
    func disconnect() {
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

    ///
    /// Clears all the data related to the current Assurance Session.
    /// Call this method when user terminates the Assurance session or when non-recoverable socket error occurs.
    ///
    func clearSessionData() {
        inboundQueue.clear()
        outboundQueue.clear()
        canStartForwarding = false
        pluginHub.notifyPluginsOnSessionTerminated()
        stateManager.connectedWebSocketURL = nil
    }
    
    /// Handles the Assurance socket connection error by showing the appropriate UI to the user.
    /// - Parameters:
    ///   - error: The `AssuranceConnectionError` representing the error
    ///   - closeCode: close code defining the reason for socket closure.
    func handleConnectionError(error: AssuranceConnectionError, closeCode: Int) {
        // if the pinCode screen is still being displayed. Then use the same webView to display error
        Log.debug(label: AssuranceConstants.LOG_TAG, "Socket disconnected with error :\(error.info.name) \n description : \(error.info.description) \n close code: \(closeCode)")

        connectionDelegate.handleConnectionError(error: error)
        pluginHub.notifyPluginsOnDisconnect(withCloseCode: closeCode)

        // since we don't give retry option for these errors and UI will be dismissed anyway, hence notify plugins for onSessionTerminated
        if !error.info.shouldRetry {
            clearSessionData()
        }
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
    
    func connectToSocketWith(url : URL) {
        self.socket.connect(withUrl: url)
    }

}
