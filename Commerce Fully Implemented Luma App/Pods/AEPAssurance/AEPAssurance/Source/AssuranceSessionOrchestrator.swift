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

/// An orchestrating component that manages the creation and teardown of sessions in response to different
/// events or work flows (scanning QR code, disconnection from PIN screen, shake gesture for QuickConnect etc).
///
/// Acts as the source of truth for all operations related to active session.
class AssuranceSessionOrchestrator: AssurancePresentationDelegate, AssuranceConnectionDelegate {

    let stateManager: AssuranceStateManager
    /// A buffer for holding the events until the initial Assurance session associated with
    /// the app launch happens. This is emptied once a session has been connected.
    var outboundEventBuffer: ThreadSafeArray<AssuranceEvent>?

    /// Flag indicating if an Assurance Session was ever terminated
    /// The purpose of this flag is to determine if the Assurance Extension has discarded any MobileCore Events
    /// MobileCore events are usually discarded after
    ///  1. Assurance SDK has timeout and shutdown after non-reception of deep link URL.
    ///  2. After an Assurance Session is terminated.
    var hasEverTerminated: Bool = false

    #if DEBUG
    var quickConnectManager: QuickConnectManager?
    var session: AssuranceSession?
    var authorizingPresentation: AssuranceAuthorizingPresentation?
    #else
    private(set) var session: AssuranceSession?
    private(set) var authorizingPresentation: AssuranceAuthorizingPresentation?
    #endif
    
    init(stateManager: AssuranceStateManager) {
        self.stateManager = stateManager
        #if DEBUG
        self.quickConnectManager = QuickConnectManager(stateManager: stateManager, uiDelegate: self)
        #endif
        self.outboundEventBuffer = ThreadSafeArray(identifier: "Session Orchestrator's OutboundBuffer array")
    }

    /// Creates and starts a new  `AssuranceSession` with the provided `AssuranceSessionDetails`.
    ///
    /// A new AssuranceSession is only created if there isn't an already existing session.
    /// Calling this method also shares the shared state for the extension with the provided session details
    ///
    /// - Parameters:
    ///    - sessionDetails: An `AssuranceSessionDetails` instance containing all the essential data for starting a session
    func createSession(withDetails sessionDetails: AssuranceSessionDetails) {
        if session != nil {
            Log.warning(label: AssuranceConstants.LOG_TAG, "An active Assurance session already exists. Cannot create a new one. Ignoring to process the scanned deeplink.")
            return
        }

        stateManager.shareAssuranceState(withSessionID: sessionDetails.sessionId)
        session = AssuranceSession(sessionDetails: sessionDetails, stateManager: stateManager, sessionOrchestrator: self, outboundEvents: outboundEventBuffer)
        session?.startSession()

        outboundEventBuffer?.clear()
        outboundEventBuffer = nil
    }
    
    #if DEBUG
    ///
    /// Starts the quick connect flow
    ///
    func startQuickConnectFlow() {
        if session != nil {
            Log.warning(label: AssuranceConstants.LOG_TAG, "An active Assurance session already exists. Cannot create a new one. Ignoring attempt to start quick connect flow.")
            return
        }

        guard let authorizingPresentation = authorizingPresentation, authorizingPresentation.sessionView is QuickConnectView else {
            self.authorizingPresentation = AssuranceAuthorizingPresentation(authorizingView: QuickConnectView(withPresentationDelegate: self))
            self.authorizingPresentation?.show()
            return
            
        }
        self.authorizingPresentation?.show()
    }
    #endif

    ///
    /// Dissolve the active session (if one exists) and its associated states.
    ///
    func terminateSession() {
        hasEverTerminated = true
        outboundEventBuffer = nil

        stateManager.clearAssuranceState()

        session?.disconnect()
        session = nil
    }

    func queueEvent(_ assuranceEvent: AssuranceEvent) {
        /// Queue this event to the active session if one exists.
        if let session = session {
            session.sendEvent(assuranceEvent)
            return
        }

        /// Drop the event if outboundEventBuffer is nil
        /// If not, we still want to queue the events to the buffer until the session is connected.
        outboundEventBuffer?.append(assuranceEvent)
    }

    /// Check if the Assurance extension is capable of handling events.
    /// Extension is capable of handling events as long as it is waiting for the first session
    /// to be established on launch or if an active session exists. This is inferred by the existence
    /// of an active session or the existence of an outboundEventBuffer.
    /// - Returns  true if extension is waiting for the first session to be established on launch (before shutting down)
    ///           or, if an active session exists.
    ///           false if extension is shutdown or no active session exists.
    func canProcessSDKEvents() -> Bool {
        return session != nil || outboundEventBuffer != nil
    }
    
    // MARK: - AssurancePresentationDelegate
    func initializePinScreenFlow() {
        guard let authorizingPresentation = authorizingPresentation, authorizingPresentation.sessionView is iOSPinCodeScreen else {
            self.authorizingPresentation = AssuranceAuthorizingPresentation(authorizingView: self.authorizingPresentation?.sessionView ?? iOSPinCodeScreen(withPresentationDelegate: self))
            self.authorizingPresentation?.show()
            return
        }
        self.authorizingPresentation?.show()
    }

    func pinScreenConnectClicked(_ pin: String) {
        guard let session = session else {
            Log.error(label: AssuranceConstants.LOG_TAG, "PIN confirmation without active session.")
            terminateSession()
            return
        }

        /// display the error if the pin is empty
        if pin.isEmpty {
            authorizingPresentation?.sessionConnectionError(error: .noPincode)
            terminateSession()
            return
        }

        /// display error if the OrgID is missing.
        guard let orgID = stateManager.getURLEncodedOrgID() else {
            authorizingPresentation?.sessionConnectionError(error: .noOrgId)
            terminateSession()
            return
        }
        
        authorizingPresentation?.sessionConnecting()
        Log.trace(label: AssuranceConstants.LOG_TAG, "Connect Button clicked. Starting a socket connection.")
        session.sessionDetails.authenticate(withPIN: pin, andOrgID: orgID)
        session.startSession()
    }
    
    func pinScreenCancelClicked() {
        Log.trace(label: AssuranceConstants.LOG_TAG, "Cancel clicked. Terminating session and dismissing the PinCode Screen.")
        terminateSession()
    }

    func disconnectClicked() {
        Log.trace(label: AssuranceConstants.LOG_TAG, "Disconnect clicked. Terminating session.")
        terminateSession()
    }

    var isConnected: Bool {
        get {
            return session?.socket.socketState == .open
        }
    }
    
#if DEBUG
    
    func quickConnectBegin() {
        quickConnectManager?.createDevice()
    }
    
    func quickConnectCancelled() {
        quickConnectManager?.cancelRetryGetDeviceStatus()
    }
    
    func createQuickConnectSession(with sessionDetails: AssuranceSessionDetails) {
        if session != nil {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Quick connect attempted when active session exists")
            return
        }
        
        authorizingPresentation?.sessionConnecting()
        createSession(withDetails: sessionDetails)
    }
    
    func quickConnectError(error: AssuranceConnectionError) {
        authorizingPresentation?.sessionConnectionError(error: error)
    }
#endif
    
    // MARK: - AssuranceConnectionDelegate
    func handleConnectionError(error: AssuranceConnectionError) {
        authorizingPresentation?.sessionConnectionError(error: error)
    }
    
    func handleSuccessfulConnection() {
        authorizingPresentation?.sessionConnected()
    }
    
    func handleSessionDisconnect() {
        authorizingPresentation?.sessionDisconnected()
    }
}
