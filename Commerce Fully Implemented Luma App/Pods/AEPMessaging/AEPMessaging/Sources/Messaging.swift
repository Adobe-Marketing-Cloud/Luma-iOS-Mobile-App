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

@objc(AEPMobileMessaging)
public class Messaging: NSObject, Extension {

    // MARK: - Class members

    public static var extensionVersion: String = MessagingConstants.EXTENSION_VERSION
    public var name = MessagingConstants.EXTENSION_NAME
    public var friendlyName = MessagingConstants.FRIENDLY_NAME
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime

    private var messagesRequestEventId: String?
    private var lastProcessedRequestEventId: String?
    private var initialLoadComplete = false
    private(set) var currentMessage: Message?
    private let rulesEngine: MessagingRulesEngine

    // MARK: - Extension protocol methods

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        rulesEngine = MessagingRulesEngine(name: MessagingConstants.RULES_ENGINE_NAME,
                                           extensionRuntime: runtime)
        super.init()
        rulesEngine.loadCachedPropositions(for: appSurface)
    }

    /// INTERNAL ONLY
    /// used for testing
    init(runtime: ExtensionRuntime, rulesEngine: MessagingRulesEngine, expectedScope: String) {
        self.runtime = runtime
        self.rulesEngine = rulesEngine
        self.rulesEngine.loadCachedPropositions(for: expectedScope)

        super.init()
    }
    
    public func onRegistered() {
        // register listener for set push identifier event
        registerListener(type: EventType.genericIdentity,
                         source: EventSource.requestContent,
                         listener: handleProcessEvent)

        // register listener for Messaging request content event
        registerListener(type: MessagingConstants.Event.EventType.messaging,
                         source: EventSource.requestContent,
                         listener: handleProcessEvent)

        // register wildcard listener for messaging rules engine
        registerListener(type: EventType.wildcard,
                         source: EventSource.wildcard,
                         listener: handleWildcardEvent)

        // register listener for rules consequences with in-app messages
        registerListener(type: EventType.rulesEngine,
                         source: EventSource.responseContent,
                         listener: handleRulesResponse)

        // register listener for edge personalization notifications
        registerListener(type: EventType.edge,
                         source: MessagingConstants.Event.Source.PERSONALIZATION_DECISIONS,
                         listener: handleEdgePersonalizationNotification)
    }

    public func onUnregistered() {
        Log.debug(label: MessagingConstants.LOG_TAG, "Extension unregistered from MobileCore: \(MessagingConstants.FRIENDLY_NAME)")
    }

    public func readyForEvent(_ event: Event) -> Bool {
        guard let configurationSharedState = getSharedState(extensionName: MessagingConstants.SharedState.Configuration.NAME, event: event),
              configurationSharedState.status == .set
        else {
            Log.trace(label: MessagingConstants.LOG_TAG, "Event processing is paused - waiting for valid configuration.")
            return false
        }

        // hard dependency on edge identity module for ecid
        guard let edgeIdentitySharedState = getXDMSharedState(extensionName: MessagingConstants.SharedState.EdgeIdentity.NAME, event: event),
              edgeIdentitySharedState.status == .set
        else {
            Log.trace(label: MessagingConstants.LOG_TAG, "Event processing is paused - waiting for valid XDM shared state from Edge Identity extension.")
            return false
        }

        // once we have valid configuration, fetch message definitions from offers if we haven't already
        if !initialLoadComplete {
            initialLoadComplete = true
            fetchMessages()
        }

        return true
    }

    // MARK: - In-app Messaging methods

    /// Called on every event, used to allow processing of the Messaging rules engine
    private func handleWildcardEvent(_ event: Event) {
        rulesEngine.process(event: event)
    }

    /// Generates and dispatches an event prompting the Edge extension to fetch in-app messages.
    /// The app surface used in the request is generated using the `bundleIdentifier` for the app.
    /// If the `bundleIdentifier` is unavailable, calling this method will do nothing.
    private func fetchMessages() {
        guard appSurface != "unknown" else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Unable to retrieve in-app messages - unable to retrieve bundle identifier.")
            return
        }

        var eventData: [String: Any] = [:]

        let messageRequestData: [String: Any] = [
            MessagingConstants.XDM.IAM.Key.PERSONALIZATION: [
                MessagingConstants.XDM.IAM.Key.SURFACES: [ appSurface ]
            ]
        ]
        eventData[MessagingConstants.XDM.IAM.Key.QUERY] = messageRequestData

        let xdmData: [String: Any] = [
            MessagingConstants.XDM.Key.EVENT_TYPE: MessagingConstants.XDM.IAM.EventType.PERSONALIZATION_REQUEST
        ]
        eventData[MessagingConstants.XDM.Key.XDM] = xdmData

        let event = Event(name: MessagingConstants.Event.Name.RETRIEVE_MESSAGE_DEFINITIONS,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: eventData)

        // equal to `requestEventId` in aep response handles
        // used for ensuring that the messaging extension is responding to the correct handle
        messagesRequestEventId = event.id.uuidString

        // send event
        runtime.dispatch(event: event)
    }

    private var appSurface: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier, !bundleIdentifier.isEmpty else {
            return "unknown"
        }

        return MessagingConstants.XDM.IAM.SURFACE_BASE + bundleIdentifier
    }

    /// Validates that the received event contains in-app message definitions and loads them in the `MessagingRulesEngine`.
    /// - Parameter event: an `Event` containing an in-app message definition in its data
    private func handleEdgePersonalizationNotification(_ event: Event) {
        // validate the event
        guard event.isPersonalizationDecisionResponse, event.requestEventId == messagesRequestEventId else {
            // either this isn't the type of response we are waiting for, or it's not a response for our request
            return
        }
        
        // if this is an event for a new request, purge cache and update lastProcessedRequestEventId
        var clearExistingRules = false
        if lastProcessedRequestEventId != event.requestEventId {
            clearExistingRules = true
            lastProcessedRequestEventId = event.requestEventId
        }
                 
        Log.trace(label: MessagingConstants.LOG_TAG, "Loading in-app message definitions from personalization:decisions network response.")
        rulesEngine.loadPropositions(event.payload, clearExisting: clearExistingRules, expectedScope: appSurface)
    }

    /// Handles Rules Consequence events containing message definitions.
    private func handleRulesResponse(_ event: Event) {
        if event.data == nil {
            Log.warning(label: MessagingConstants.LOG_TAG, "Unable to process a Rules Consequence Event. Event data is null.")
            return
        }

        if event.isInAppMessage, event.containsValidInAppMessage {
            showMessageForEvent(event)
        } else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Unable to process In-App Message - html property is required.")
            return
        }
    }

    /// Creates and shows a fullscreen message as defined by the contents of the provided `Event`'s data.
    /// - Parameter event: the `Event` containing data necessary to create the message and report on it
    private func showMessageForEvent(_ event: Event) {
        guard event.html != nil else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to show message for event \(event.id) - it contains no HTML defining the message.")
            return
        }

        let message = Message(parent: self, event: event)
        message.propositionInfo = rulesEngine.propositionInfoForMessageId(message.id)
        if message.propositionInfo == nil {
            // swiftlint:disable line_length
            Log.warning(label: MessagingConstants.LOG_TAG, "Preparing to show a message that does not contain information necessary for tracking with Adobe Journey Optimizer. If you are spoofing this message from the AJO authoring UI or from Assurance, ignore this message.")
            // swiftlint:enable line_length
        }

        message.trigger()
        message.show(withMessagingDelegateControl: true)
        currentMessage = message
    }

    // MARK: - Event Handers

    /// Processes the events in the event queue in the order they were received.
    ///
    /// A valid `Configuration` and `EdgeIdentity` shared state is required for processing events.
    ///
    /// - Parameters:
    ///   - event: An `Event` to be processed
    func handleProcessEvent(_ event: Event) {
        if event.data == nil {
            Log.debug(label: MessagingConstants.LOG_TAG, "Process event handling ignored as event does not have any data - `\(event.id)`.")
            return
        }

        // hard dependency on configuration shared state
        guard let configSharedState = getSharedState(extensionName: MessagingConstants.SharedState.Configuration.NAME, event: event)?.value else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Event processing is paused, waiting for valid configuration - '\(event.id.uuidString)'.")
            return
        }

        // handle an event for refreshing in-app messages from the remote
        if event.isRefreshMessageEvent {
            Log.debug(label: MessagingConstants.LOG_TAG, "Processing manual request to refresh In-App Message definitions from the remote.")
            fetchMessages()
            return
        }

        // hard dependency on edge identity module for ecid
        guard let edgeIdentitySharedState = getXDMSharedState(extensionName: MessagingConstants.SharedState.EdgeIdentity.NAME, event: event)?.value else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Event processing is paused, for valid xdm shared state from edge identity - '\(event.id.uuidString)'.")
            return
        }

        if event.isGenericIdentityRequestContentEvent {
            guard let token = event.token, !token.isEmpty else {
                Log.debug(label: MessagingConstants.LOG_TAG, "Ignoring event with missing or invalid push identifier - '\(event.id.uuidString)'.")
                return
            }

            // If the push token is valid update the shared state.
            runtime.createSharedState(data: [MessagingConstants.SharedState.Messaging.PUSH_IDENTIFIER: token], event: event)

            // get identityMap from the edge identity xdm shared state
            guard let identityMap = edgeIdentitySharedState[MessagingConstants.SharedState.EdgeIdentity.IDENTITY_MAP] as? [AnyHashable: Any] else {
                Log.warning(label: MessagingConstants.LOG_TAG, "Cannot process event that identity map is not available" +
                                "from edge identity xdm shared state - '\(event.id.uuidString)'.")
                return
            }

            // get the ECID array from the identityMap
            guard let ecidArray = identityMap[MessagingConstants.SharedState.EdgeIdentity.ECID] as? [[AnyHashable: Any]],
                  !ecidArray.isEmpty, let ecid = ecidArray[0][MessagingConstants.SharedState.EdgeIdentity.ID] as? String,
                  !ecid.isEmpty
            else {
                Log.warning(label: MessagingConstants.LOG_TAG, "Cannot process event as ecid is not available in the identity map - '\(event.id.uuidString)'.")
                return
            }

            sendPushToken(ecid: ecid, token: token, platform: getPushPlatform(forEvent: event))
        }

        // Check if the event type is `MessagingConstants.Event.EventType.messaging` and
        // eventSource is `EventSource.requestContent` handle processing of the tracking information
        if event.isMessagingRequestContentEvent, configSharedState.keys.contains(MessagingConstants.SharedState.Configuration.EXPERIENCE_EVENT_DATASET) {
            handleTrackingInfo(event: event)
            return
        }
    }
    
    #if DEBUG
    /// Used for testing only
    internal func setMessagesRequestEventId(_ newId: String?) {
        messagesRequestEventId = newId
    }
    
    /// Used for testing only
    internal func setLastProcessedRequestEventId(_ newId: String?) {
        lastProcessedRequestEventId = newId
    }
    #endif
}
