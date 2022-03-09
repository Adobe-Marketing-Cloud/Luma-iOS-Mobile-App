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
    public static var extensionVersion: String = MessagingConstants.EXTENSION_VERSION
    public var name = MessagingConstants.EXTENSION_NAME
    public var friendlyName = MessagingConstants.FRIENDLY_NAME
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime

    // =================================================================================================================
    // MARK: - ACPExtension protocol methods
    // =================================================================================================================
    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        super.init()
    }

    public func onRegistered() {
        // register listener for set push identifier event
        registerListener(type: EventType.genericIdentity,
                         source: EventSource.requestContent,
                         listener: handleProcessEvent)

        // register listener for Messaging request content event
        registerListener(type: MessagingConstants.EventType.messaging,
                         source: EventSource.requestContent,
                         listener: handleProcessEvent)
    }

    public func onUnregistered() {
        print("Extension unregistered from MobileCore: \(MessagingConstants.FRIENDLY_NAME)")
    }

    public func readyForEvent(_ event: Event) -> Bool {
        guard let configurationSharedState = getSharedState(extensionName: MessagingConstants.SharedState.Configuration.NAME, event: event) else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Event processing is paused, waiting for valid configuration - '\(event.id.uuidString)'.")
            return false
        }

        // hard dependency on edge identity module for ecid
        guard let edgeIdentitySharedState = getXDMSharedState(extensionName: MessagingConstants.SharedState.EdgeIdentity.NAME, event: event) else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Event processing is paused, waiting for valid xdm shared state from edge identity - '\(event.id.uuidString)'.")
            return false
        }

        return configurationSharedState.status == .set && edgeIdentitySharedState.status == .set
    }

    // =================================================================================================================
    // MARK: - Event Handers
    // =================================================================================================================

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
                !ecid.isEmpty else {
                    Log.warning(label: MessagingConstants.LOG_TAG, "Cannot process event as ecid is not available in the identity map - '\(event.id.uuidString)'.")
                    return
            }

            sendPushToken(ecid: ecid, token: token, platform: getPlatform(config: configSharedState))
        }

        // Check if the event type is `MessagingConstants.EventType.MESSAGING` and
        // eventSource is `EventSource.requestContent` handle processing of the tracking information
        if event.isMessagingRequestContentEvent, configSharedState.keys.contains(MessagingConstants.SharedState.Configuration.EXPERIENCE_EVENT_DATASET) {
            handleTrackingInfo(event: event, configSharedState)
            return
        }
    }

    /// Send an edge event to sync the push notification details with push token
    ///
    /// - Parameters:
    ///   - ecid: Experience cloud id
    ///   - token: Push token for the device
    ///   - platform: `String` denoting the platform `apns` or `apnsSandbox`
    private func sendPushToken(ecid: String, token: String, platform: String) {
        // send the request
        guard let appId: String = Bundle.main.bundleIdentifier else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to sync the push token, App bundle identifier is invalid.")
            return
        }

        // Create the profile experience event to send the push notification details with push token to profile
        let profileEventData: [String: Any] = [
            MessagingConstants.PushNotificationDetails.PUSH_NOTIFICATION_DETAILS: [
                [MessagingConstants.PushNotificationDetails.APP_ID: appId,
                 MessagingConstants.PushNotificationDetails.TOKEN: token,
                 MessagingConstants.PushNotificationDetails.PLATFORM: platform,
                 MessagingConstants.PushNotificationDetails.DENYLISTED: false,
                 MessagingConstants.PushNotificationDetails.IDENTITY: [
                    MessagingConstants.PushNotificationDetails.NAMESPACE: [
                        MessagingConstants.PushNotificationDetails.CODE: MessagingConstants.PushNotificationDetails.JsonValues.ECID
                    ],
                    MessagingConstants.PushNotificationDetails.ID: ecid
                    ]]
            ]
        ]

        // Creating xdm edge event data
        let xdmEventData: [String: Any] = [MessagingConstants.XDMDataKeys.DATA: profileEventData]
        // Creating xdm edge event with request content source type
        let event = Event(name: MessagingConstants.EventName.PUSH_PROFILE_EDGE,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: xdmEventData)
        dispatch(event: event)
    }

    /// Sends an experience event to the platform sdk for tracking the notification click-throughs
    /// - Parameters:
    ///   - event: The triggering event with the click through data
    ///   - config: configuration data
    /// - Returns: A boolean explaining whether the handling of tracking info was successful or not
    private func handleTrackingInfo(event: Event, _ config: [AnyHashable: Any]) {
        guard let expEventDatasetId = config[MessagingConstants.SharedState.Configuration.EXPERIENCE_EVENT_DATASET] as? String, !expEventDatasetId.isEmpty else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to handle tracking information for push notification: " +
                "Experience event dataset ID from the config is invalid or not available. '\(event.id.uuidString)'")
            return
        }

        // Get the xdm data with push tracking details
        guard var xdmMap = getXdmData(event: event, config: config) else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to handle tracking information for push notification: " +
                "Error while creating xdmMap with the push tracking details from the event and config. '\(event.id.uuidString)'")
            return
        }

        // Add application specific tracking data
        let applicationOpened = event.applicationOpened
        xdmMap = addApplicationData(applicationOpened: applicationOpened, xdmData: xdmMap)

        // Add Adobe specific tracking data
        xdmMap = addAdobeData(event: event, xdmDict: xdmMap)

        // Creating xdm edge event data
        let xdmEventData: [String: Any] = [MessagingConstants.XDMDataKeys.XDM: xdmMap, MessagingConstants.XDMDataKeys.META: [
            MessagingConstants.XDMDataKeys.COLLECT: [
                MessagingConstants.XDMDataKeys.DATASET_ID: expEventDatasetId
            ]
            ]]
        // Creating xdm edge event with request content source type
        let event = Event(name: MessagingConstants.EventName.PUSH_TRACKING_EDGE,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: xdmEventData)
        dispatch(event: event)
    }

    /// Adding Adobe/CJM specific data to tracking information map.
    /// - Parameters:
    ///  - event: `Event` with Adobe cjm tracking information
    ///  - xdmDict: `[AnyHashable: Any]` which is updated with the cjm tracking information.
    private func addAdobeData(event: Event, xdmDict: [String: Any]) -> [String: Any] {
        var xdmDictResult = xdmDict
        if event.adobeXdm == nil {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to update xdmMap with adobe/cjm related informations : adobe/cjm information are invalid or not available in the event '\(event.id.uuidString)'.")
            return xdmDictResult
        }

        // Check if the json has the required keys
        var mixins: [String: Any]? = event.mixins
        // If key `mixins` is not present check for cjm
        if mixins == nil {
            // check if CJM key is not present return the orginal xdmDict
            guard let cjm: [String: Any] = event.cjm else {
                Log.warning(label: MessagingConstants.LOG_TAG,
                            "Failed to update xdmMap with adobe/cjm informations : Adobe/CJM data is not avilable in the event '\(event.id.uuidString)'.")
                return xdmDictResult
            }
            mixins = cjm
        }

        // Add all the key and value pair to xdmDictResult
        xdmDictResult += mixins ?? [:]

        // Check if the xdm data provided by the customer is using cjm for tracking
        // Check if both `MessagingConstant.AdobeTrackingKeys.EXPERIENCE` and `MessagingConstant.AdobeTrackingKeys.CUSTOMER_JOURNEY_MANAGEMENT` exists
        if var experienceDict = xdmDictResult[MessagingConstants.AdobeTrackingKeys.EXPERIENCE] as? [String: Any] {
            if var cjmDict = experienceDict[MessagingConstants.AdobeTrackingKeys.CUSTOMER_JOURNEY_MANAGEMENT] as? [String: Any] {
                // Adding Message profile and push channel context to CUSTOMER_JOURNEY_MANAGEMENT
                guard let messageProfile = convertStringToDictionary(
                    jsonString: MessagingConstants.AdobeTrackingKeys.MESSAGE_PROFILE_JSON) else {
                        Log.warning(label: MessagingConstants.LOG_TAG,
                                    "Failed to update xdmMap with adobe/cjm informations:" +
                            "converting message profile string to dictionary failed in the event '\(event.id.uuidString)'.")
                        return xdmDictResult
                }
                // Merging the dictionary
                cjmDict += messageProfile
                experienceDict[MessagingConstants.AdobeTrackingKeys.CUSTOMER_JOURNEY_MANAGEMENT] = cjmDict
                xdmDictResult[MessagingConstants.AdobeTrackingKeys.EXPERIENCE] = experienceDict
            }
        } else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to send adobe/cjm information data with the tracking," +
                "\(MessagingConstants.AdobeTrackingKeys.EXPERIENCE) is missing in the event '\(event.id.uuidString)'.")
        }
        return xdmDictResult
    }

    /// Adding application data based on the application opened or not
    /// - Parameters:
    ///   - applicationOpened: `Bool` stating whether the application is opened or not
    ///   - xdmData: `[AnyHashable: Any]` xdm data in which application data needs to be added
    /// - Returns: `[String: Any]` which conatins the application data
    private func addApplicationData(applicationOpened: Bool, xdmData: [String: Any]) -> [String: Any] {
        var xdmDataResult = xdmData
        xdmDataResult[MessagingConstants.AdobeTrackingKeys.APPLICATION] =
            [MessagingConstants.AdobeTrackingKeys.LAUNCHES:
                [MessagingConstants.AdobeTrackingKeys.LAUNCHES_VALUE: applicationOpened ? 1 : 0]]
        return xdmDataResult
    }

    /// Creates the xdm schema from event data
    /// - Parameters:
    ///   - event: `Event` with push notification tracking information
    ///   - config: `[AnyHashable: Any]` with configuration informations
    /// - Returns: `[String: Any]?` which contains the xdm data
    private func getXdmData(event: Event, config: [AnyHashable: Any]) -> [String: Any]? {
        guard let eventType = event.eventType else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Updating xdm data for tracking failed, eventType is invalid or nil in the event '\(event.id.uuidString)'.")
            return nil
        }
        let messageId = event.messagingId
        let actionId = event.actionId

        if eventType.isEmpty == true || messageId == nil || messageId?.isEmpty == true {
            Log.trace(label: MessagingConstants.LOG_TAG, "Updating xdm data for tracking failed, EventType or MessageId received in the event '\(event.id.uuidString)' is nil.")
            return nil
        }

        var xdmDict: [String: Any] = [MessagingConstants.XDMDataKeys.EVENT_TYPE: eventType]
        var pushNotificationTrackingDict: [String: Any] = [:]
        var customActionDict: [String: Any] = [:]
        if actionId != nil {
            customActionDict[MessagingConstants.XDMDataKeys.ACTION_ID] = actionId
            pushNotificationTrackingDict[MessagingConstants.XDMDataKeys.CUSTOM_ACTION] = customActionDict
        }
        pushNotificationTrackingDict[MessagingConstants.XDMDataKeys.PUSH_PROVIDER_MESSAGE_ID] = messageId
        pushNotificationTrackingDict[MessagingConstants.XDMDataKeys.PUSH_PROVIDER] = getPlatform(config: config)
        xdmDict[MessagingConstants.XDMDataKeys.PUSH_NOTIFICATION_TRACKING] = pushNotificationTrackingDict

        return xdmDict
    }

    // MARK: - Private - Helper methods

    /// Converts a json string into dictionary object.
    /// - Parameters:
    ///   - jsonString: json String that needs to be converted to a dictionary
    /// - Returns: A  dictionary representation of the string. Returns `nil` if the json serialization of the string fails.
    private func convertStringToDictionary(jsonString: String) -> [String: Any]? {
        if let data = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                Log.debug(label: MessagingConstants.LOG_TAG, "Unexpected error occurred while converting string \(jsonString) to dictionary: Error -  \(error).")
                return nil
            }
        }
        return nil
    }

    /// Get platform based on the `messaging.useSandbox` config value
    /// - Parameters:
    ///     - config: `[AnyHashable: Any]` with platform informations
    private func getPlatform(config: [AnyHashable: Any]) -> String {
        return config[MessagingConstants.SharedState.Configuration.USE_SANDBOX] as? Bool ?? false
            ? MessagingConstants.PushNotificationDetails.JsonValues.APNS_SANDBOX
            : MessagingConstants.PushNotificationDetails.JsonValues.APNS
    }
}

/// Use to merge 2 dictionaries together
func += <K, V>(left: inout [K: V], right: [K: V]) {
    left.merge(right) { _, new in new }
}
