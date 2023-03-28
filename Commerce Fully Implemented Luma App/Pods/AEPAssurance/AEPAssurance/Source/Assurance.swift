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

import AEPCore
import AEPServices
import Foundation

@objc(AEPMobileAssurance)
public class Assurance: NSObject, Extension {
    

    public var name = AssuranceConstants.EXTENSION_NAME
    public var friendlyName = AssuranceConstants.FRIENDLY_NAME
    public static var extensionVersion = AssuranceConstants.EXTENSION_VERSION
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime

    var timer: DispatchSourceTimer?

    #if DEBUG
    /// following variables are made editable for testing purposes
    var shutdownTime: TimeInterval /// Time before which Assurance extension shuts down on non receipt of start session event.
    var stateManager: AssuranceStateManager
    var sessionOrchestrator: AssuranceSessionOrchestrator
    var quickConnect: QuickConnectManager?
    #else
    let shutdownTime: TimeInterval
    let stateManager: AssuranceStateManager
    let sessionOrchestrator: AssuranceSessionOrchestrator
    #endif
    
    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        self.shutdownTime = AssuranceConstants.SHUTDOWN_TIME
        self.stateManager = AssuranceStateManager(runtime)
        self.sessionOrchestrator = AssuranceSessionOrchestrator(stateManager: stateManager)
    }

    public func onRegistered() {
        registerListener(type: EventType.wildcard, source: EventSource.wildcard, listener: handleWildcardEvent)

        /// if the Assurance session was already connected in the previous app session, go ahead and reconnect socket
        /// and do not turn on the unregister timer
        if let connectedWebSocketURLString = stateManager.connectedWebSocketURL {
            Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance Session was already connected during previous app launch. Attempting to reconnect. URL : \(String(describing: connectedWebSocketURLString))")
            do {
                let sessionDetails = try AssuranceSessionDetails(withURLString: connectedWebSocketURLString)
                sessionOrchestrator.createSession(withDetails: sessionDetails)
                return
            } catch let error as AssuranceSessionDetailBuilderError {
                Log.warning(label: AssuranceConstants.LOG_TAG, "Ignoring to reconnect to already connected session. Invalid socket url.  URL : \(String(describing: connectedWebSocketURLString)) Error Message: \(error.message)")
            } catch {
                Log.warning(label: AssuranceConstants.LOG_TAG, "Ignoring to reconnect to already connected session. Invalid socket url.  URL : \(String(describing: connectedWebSocketURLString)) Error Message: \(error.localizedDescription)")
            }
        }
        
        /// if the Assurance session is not previously connected, turn on 5 sec timer to wait for Assurance deeplink
        startShutDownTimer()
    }

    public func onUnregistered() {}


    public func readyForEvent(_ event: Event) -> Bool {
        return true
    }

    // MARK: - Event handlers

    /// Called by the wildcard listener to handle all the events dispatched from MobileCore's event hub.
    /// If an Assurance Session connection was established, each mobile core event is converted
    /// to `AssuranceEvent` and is sent over the socket.
    /// - Parameters:
    /// - event - a MobileCore's `Event`
    private func handleWildcardEvent(event: Event) {
        if event.isAssuranceRequestContent {
            handleAssuranceRequestContent(event: event)
        }

        /// Handle wildcard event only
        /// 1. If there is an active session running
        /// 2. If Assurance extension is collecting events before the 5 second timeout
        if !(sessionOrchestrator.canProcessSDKEvents()) {
            return
        }

        /// If the event is a sharedState change event
        /// then attach the sharedState data to it before sending to over socket
        if event.isSharedStateEvent {
            processSharedStateEvent(event: event)
            return
        }

        /// forward all other events to Assurance session
        let assuranceEvent = AssuranceEvent.from(event: event)
        sessionOrchestrator.queueEvent(assuranceEvent)

        /// NearbyPOIs and Places entry/exits events are logged in the Status UI
        if event.isPlacesRequestEvent {
            handlePlacesRequest(event: event)
        } else if event.isPlacesResponseEvent {
            handlePlacesResponse(event: event)
        }
    }

    /// Call to handle MobileCore's event of type `Assurance` and source `RequestContent`
    ///
    /// These are typically the events that are generated when startSession API is called.
    /// This event contains the deeplink information to kickStart an Assurance session.
    ///
    /// - Parameters:
    /// - event - a AssuranceRequestContent event with deeplink data
    private func handleAssuranceRequestContent(event: Event) {
        /// early bail out if eventData is nil
        guard let startSessionData = event.data else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with empty data. Dropping event.")
            return
        }
        
        #if DEBUG
        if let isQuickConnect = startSessionData[AssuranceConstants.EventDataKey.QUICK_CONNECT] as? Bool, isQuickConnect {
            invalidateTimer()
            sessionOrchestrator.startQuickConnectFlow()
            return
        }
        #endif

        guard let deeplinkUrlString = startSessionData[AssuranceConstants.EventDataKey.START_SESSION_URL] as? String else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with no deeplink url. Dropping event.")
            return
        }

        let deeplinkURL = URL(string: deeplinkUrlString)
        guard let sessionId = deeplinkURL?.params[AssuranceConstants.Deeplink.SESSIONID_KEY] else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with invalid deeplink url. URL does not contain 'adb_validation_sessionid' query parameter : " + deeplinkUrlString)
            return
        }

        // make sure the sessionID is an UUID string
        guard let _ = UUID(uuidString: sessionId) else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with invalid deeplink url. It contains sessionId that is not an valid UUID : " + deeplinkUrlString)
            return
        }

        // Read the environment query parameter from the deeplink url
        let environmentString = deeplinkURL?.params[AssuranceConstants.Deeplink.ENVIRONMENT_KEY] ?? ""

        // invalidate the timer
        invalidateTimer()

        let sessionDetails = AssuranceSessionDetails(sessionId: sessionId, clientId: stateManager.clientID, environment: AssuranceEnvironment.init(envString: environmentString))
        Log.trace(label: AssuranceConstants.LOG_TAG, "Assurance start session event received with sessionId : \(sessionId), Initializing Assurance session.")
        sessionOrchestrator.createSession(withDetails: sessionDetails)
    }

    // MARK: Places event handlers

    /// Handle places request events and log them in the client statusUI.
    ///
    /// - Parameters:
    ///     - event - a mobileCore's places request event
    private func handlePlacesRequest(event: Event) {
        if event.isRequestNearByPOIEvent {
            sessionOrchestrator.session?.statusPresentation.addClientLog("Places - Requesting \(event.poiCount) nearby POIs from (\(event.latitude), \(event.longitude))", visibility: .normal)
        } else if event.isRequestResetEvent {
            sessionOrchestrator.session?.statusPresentation.addClientLog("Places - Resetting location", visibility: .normal)
        }
    }

    /// Handle places response events and log them in the client statusUI.
    ///
    /// - Parameters:
    ///     - event - a mobileCore's places response event
    private func handlePlacesResponse(event: Event) {
        if event.isResponseRegionEvent {
            sessionOrchestrator.session?.statusPresentation.addClientLog("Places - Processed \(event.regionEventType) for region \(event.regionName).", visibility: .normal)
        } else if event.isResponseNearByEvent {
            let nearByPOIs = event.nearByPOIs
            for poi in nearByPOIs {
                guard let poiDictionary = poi as? [String: Any] else {
                    return
                }
                sessionOrchestrator.session?.statusPresentation.addClientLog("\t  \(poiDictionary["regionname"] as? String ?? "Unknown")", visibility: .high)
            }
            sessionOrchestrator.session?.statusPresentation.addClientLog("Places - Found \(nearByPOIs.count) nearby POIs\(!nearByPOIs.isEmpty ? " :" : ".")", visibility: .high)
        }
    }

    /// Method to process the sharedState events from the event hub.
    /// Shared State Change events are special events to Assurance.  On the arrival of which, Assurance extension attempts to
    /// extract the shared state details associated with the shared state change, and then append them to this event.
    /// Assurance extension handles both regular and XDM shared state change events.
    ///
    /// - Parameter event - a mobileCore's `Event`
    private func processSharedStateEvent(event: Event) {
        // early bail out if unable to find the stateOwner
        guard let stateOwner = event.sharedStateOwner else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to find shared state owner for the shared state change event. Dropping event.")
            return
        }

        // Differentiate the type of shared state using the event name and get the state content accordingly
        // Event Name for XDM shared          = "Shared state content (XDM)"
        // Event Name for Regular  shared     = "Shared state content"
        var sharedStateResult: SharedStateResult?
        var sharedContentKey: String

        if AssuranceConstants.SDKEventName.XDM_SHARED_STATE_CHANGE.lowercased() == event.name.lowercased() {
            sharedContentKey = AssuranceConstants.PayloadKey.XDM_SHARED_STATE_DATA
            sharedStateResult = runtime.getXDMSharedState(extensionName: stateOwner, event: nil, barrier: false)
        } else {
            sharedContentKey = AssuranceConstants.PayloadKey.SHARED_STATE_DATA
            sharedStateResult = runtime.getSharedState(extensionName: stateOwner, event: nil, barrier: false)
        }

        // do not send any sharedState thats empty, this includes Assurance not logging any pending shared states
        guard let sharedState = sharedStateResult else {
            return
        }

        if sharedState.status != .set {
            return
        }

        let sharedStatePayload = [sharedContentKey: sharedState.value]
        var assuranceEvent = AssuranceEvent.from(event: event)
        assuranceEvent.payload?.updateValue(AnyCodable.init(sharedStatePayload), forKey: AssuranceConstants.PayloadKey.METADATA)
        sessionOrchestrator.queueEvent(assuranceEvent)
    }

    // MARK: Shutdown timer methods

    /// Start the shutdown timer in the background queue without blocking the current thread.
    /// If the timer get fired, then it shuts down the assurance extension.
    private func startShutDownTimer() {
        Log.debug(label: AssuranceConstants.LOG_TAG, "Assurance shutdown timer started. Waiting for 5 seconds to receive assurance session url.")
        let queue = DispatchQueue.init(label: "com.adobe.assurance.shutdowntimer", qos: .background)
        timer = createDispatchTimer(queue: queue, block: {
            self.shutDownAssurance()
        })
    }

    /// Shuts down the assurance extension by setting the `shouldProcessEvents` to false. On which no more events
    /// are listened by assurance extension
    /// @see readyForEvent
    private func shutDownAssurance() {
        Log.debug(label: AssuranceConstants.LOG_TAG, "Timeout - Assurance extension did not receive session url. Shutting down from processing any further events.")
        invalidateTimer()
        Log.debug(label: AssuranceConstants.LOG_TAG, "Clearing the queued events and purging Assurance shared state.")
        sessionOrchestrator.terminateSession()
    }

    /// Invalidate the ongoing timer and cleans it from memory
    func invalidateTimer() {
        timer?.cancel()
        timer = nil
    }

    /// Creates and returns a new dispatch source object for timer events.
    /// The timer is set to fire in 5 seconds on the provided block.
    /// - Parameters:
    ///     - queue: the dispatch queue on which the timer runs
    ///     - block: the block that needs be executed once the timer fires
    /// - Returns: a configured `DispatchSourceTimer` instance
    private func createDispatchTimer(queue: DispatchQueue, block : @escaping () -> Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(wallDeadline: .now() + shutdownTime)
        timer.setEventHandler(handler: block)
        timer.resume()
        return timer
    }
}
