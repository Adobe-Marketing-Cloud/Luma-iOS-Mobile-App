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

extension Messaging {
    // MARK: - internal methods

    /// Sends an experience event to the platform SDK for tracking the notification click-throughs
    ///
    /// - Parameters:
    ///   - event: The triggering event with the click through data
    func handleTrackingInfo(event: Event) {
        guard let datasetId = getDatasetId(forEvent: event) else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to handle tracking information for push notification: " +
                            "Experience event dataset ID from the config is invalid or not available. '\(event.id.uuidString)'")
            return
        }

        // Get the xdm data with push tracking details
        guard var xdmMap = getXdmData(event: event) else {
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
        let xdmEventData: [String: Any] = [
            MessagingConstants.XDM.Key.XDM: xdmMap,
            MessagingConstants.XDM.Key.META: [
                MessagingConstants.XDM.Key.COLLECT: [
                    MessagingConstants.XDM.Key.DATASET_ID: datasetId
                ]
            ]
        ]

        // Creating xdm edge event with request content source type
        let event = Event(name: MessagingConstants.Event.Name.PUSH_TRACKING_EDGE,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: xdmEventData)
        dispatch(event: event)
    }

    /// Send an edge event to sync the push notification details with push token
    ///
    /// - Parameters:
    ///   - ecid: Experience cloud id
    ///   - token: Push token for the device
    ///   - platform: `String` denoting the platform `apns` or `apnsSandbox`
    func sendPushToken(ecid: String, token: String, platform: String) {
        // send the request
        guard let appId: String = Bundle.main.bundleIdentifier else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to sync the push token, App bundle identifier is invalid.")
            return
        }

        // Create the profile experience event to send the push notification details with push token to profile
        let profileEventData: [String: Any] = [
            MessagingConstants.XDM.Push.PUSH_NOTIFICATION_DETAILS: [
                [MessagingConstants.XDM.Push.APP_ID: appId,
                 MessagingConstants.XDM.Push.TOKEN: token,
                 MessagingConstants.XDM.Push.PLATFORM: platform,
                 MessagingConstants.XDM.Push.DENYLISTED: false,
                 MessagingConstants.XDM.Push.IDENTITY: [
                    MessagingConstants.XDM.Push.NAMESPACE: [
                        MessagingConstants.XDM.Push.CODE: MessagingConstants.XDM.Push.Value.ECID
                    ],
                    MessagingConstants.XDM.Push.ID: ecid
                 ]]
            ]
        ]

        // Creating xdm edge event data
        let xdmEventData: [String: Any] = [MessagingConstants.XDM.Key.DATA: profileEventData]
        // Creating xdm edge event with request content source type
        let event = Event(name: MessagingConstants.Event.Name.PUSH_PROFILE_EDGE,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: xdmEventData)
        dispatch(event: event)
    }

    // MARK: - private methods

    /// Adding Adobe/AJO specific data to tracking information map.
    ///
    /// - Parameters:
    ///  - event: `Event` with Adobe AJO tracking information
    ///  - xdmDict: `[String: Any]` which is updated with the AJO tracking information.
    /// - Returns: a dictionary combining Adobe related data with the provided `xdmDict`
    private func addAdobeData(event: Event, xdmDict: [String: Any]) -> [String: Any] {
        // make sure this event has adobe xdm data
        guard event.adobeXdm != nil else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to update xdmMap with Adobe/AJO related informations : Adobe/AJO information are invalid or not available in the event '\(event.id.uuidString)'.")
            return xdmDict
        }

        // required keys are found using the following priority
        // 1. check the event's "mixins" key
        // 2. check the event's "cjm" key
        var mixins: [String: Any]
        if event.mixins != nil {
            // swiftlint:disable all
            mixins = event.mixins!
            // swiftlint:enable all
        } else {
            guard let cjm = event.cjm else {
                Log.warning(label: MessagingConstants.LOG_TAG,
                            "Failed to update xdmMap with Adobe/AJO information : Adobe/AJO data is not available in the event '\(event.id.uuidString)'.")
                return xdmDict
            }

            mixins = cjm
        }

        var xdmDictResult = xdmDict

        // Add all the key and value pair to xdmDictResult
        xdmDictResult.mergeXdm(rhs: mixins)

        // Check if the xdm data provided by the customer is using cjm for tracking
        // Check if both `MessagingConstant.AdobeTrackingKeys.EXPERIENCE` and `MessagingConstant.AdobeTrackingKeys.CUSTOMER_JOURNEY_MANAGEMENT` exists
        if var experienceDict = xdmDictResult[MessagingConstants.XDM.AdobeKeys.EXPERIENCE] as? [String: Any] {
            if var cjmDict = experienceDict[MessagingConstants.XDM.AdobeKeys.CUSTOMER_JOURNEY_MANAGEMENT] as? [String: Any] {
                // Adding Message profile and push channel context to CUSTOMER_JOURNEY_MANAGEMENT
                guard let messageProfile = MessagingConstants.XDM.AdobeKeys.MESSAGE_PROFILE_JSON.toJsonDictionary() else {
                    Log.warning(label: MessagingConstants.LOG_TAG,
                                "Failed to update xdmMap with adobe/cjm informations:" +
                                    "converting message profile string to dictionary failed in the event '\(event.id.uuidString)'.")
                    return xdmDictResult
                }
                // Merging the dictionary
                cjmDict.mergeXdm(rhs: messageProfile)
                experienceDict[MessagingConstants.XDM.AdobeKeys.CUSTOMER_JOURNEY_MANAGEMENT] = cjmDict
                xdmDictResult[MessagingConstants.XDM.AdobeKeys.EXPERIENCE] = experienceDict
            }
        } else {
            Log.warning(label: MessagingConstants.LOG_TAG,
                        "Failed to send adobe/cjm information data with the tracking," +
                            "\(MessagingConstants.XDM.AdobeKeys.EXPERIENCE) is missing in the event '\(event.id.uuidString)'.")
        }
        return xdmDictResult
    }

    /// Adding application data based on the application opened or not
    /// - Parameters:
    ///   - applicationOpened: `Bool` stating whether the application is opened or not
    ///   - xdmData: `[AnyHashable: Any]` xdm data in which application data needs to be added
    /// - Returns: `[String: Any]` which contains the application data
    private func addApplicationData(applicationOpened: Bool, xdmData: [String: Any]) -> [String: Any] {
        var xdmDataResult = xdmData
        xdmDataResult[MessagingConstants.XDM.AdobeKeys.APPLICATION] = [
            MessagingConstants.XDM.AdobeKeys.LAUNCHES: [
                MessagingConstants.XDM.AdobeKeys.LAUNCHES_VALUE: applicationOpened ? 1 : 0
            ]
        ]
        return xdmDataResult
    }

    /// Creates the xdm schema from event data
    /// - Parameters:
    ///   - event: `Event` with push notification tracking information
    /// - Returns: `[String: Any]?` which contains the xdm data
    private func getXdmData(event: Event) -> [String: Any]? {
        guard let xdmEventType = event.xdmEventType else {
            Log.warning(label: MessagingConstants.LOG_TAG, "Updating xdm data for tracking failed, eventType is invalid or nil in the event '\(event.id.uuidString)'.")
            return nil
        }
        let messageId = event.messagingId
        let actionId = event.actionId

        if xdmEventType.isEmpty == true || messageId == nil || messageId?.isEmpty == true {
            Log.trace(label: MessagingConstants.LOG_TAG, "Updating xdm data for tracking failed, EventType or MessageId received in the event '\(event.id.uuidString)' is nil.")
            return nil
        }

        var xdmDict: [String: Any] = [MessagingConstants.XDM.Key.EVENT_TYPE: xdmEventType]
        var pushNotificationTrackingDict: [String: Any] = [:]
        var customActionDict: [String: Any] = [:]
        if actionId != nil {
            customActionDict[MessagingConstants.XDM.Key.ACTION_ID] = actionId
            pushNotificationTrackingDict[MessagingConstants.XDM.Key.CUSTOM_ACTION] = customActionDict
        }
        pushNotificationTrackingDict[MessagingConstants.XDM.Key.PUSH_PROVIDER_MESSAGE_ID] = messageId
        pushNotificationTrackingDict[MessagingConstants.XDM.Key.PUSH_PROVIDER] = getPushPlatform(forEvent: event)
        xdmDict[MessagingConstants.XDM.Key.PUSH_NOTIFICATION_TRACKING] = pushNotificationTrackingDict

        return xdmDict
    }

    /// Retrieves the Messaging event datasetId from configuration shared state
    ///
    /// - Parameter event: the `Event` needed for retrieving the correct shared state
    /// - Returns: a `String` containing the event datasetId for Messaging
    private func getDatasetId(forEvent event: Event? = nil) -> String? {
        guard let configuration = getSharedState(extensionName: MessagingConstants.SharedState.Configuration.NAME, event: event),
              let datasetId = configuration.experienceEventDataset
        else {
            return nil
        }

        return datasetId.isEmpty ? nil : datasetId
    }

    /// Gets the push platform based on the value in `messaging.useSandbox` of Configuration's shared state
    ///
    /// If no `event` is provided, this method will use the most recent shared state for Configuration.
    /// If Configuration shared state is not retrievable, this method returns the string "apns"
    ///
    /// - Parameters:
    ///     - event: `Event` from which Configuration shared state should be derived
    /// - Returns: a `String` indicating the APNS platform in use
    func getPushPlatform(forEvent event: Event? = nil) -> String {
        guard let configuration = getSharedState(extensionName: MessagingConstants.SharedState.Configuration.NAME, event: event) else {
            return MessagingConstants.XDM.Push.Value.APNS
        }

        return configuration.pushPlatform
    }

    /// {
    ///     "xdm": {
    ///         "eventType": "decisioning.propositionInteract",
    ///         "_experience": {
    ///             "decisioning": {
    ///                 "propositionEventType": {
    ///                     "interact": 1,
    ///                     "dismiss": 1
    ///                 },
    ///                 "propositionAction": {
    ///                     "id": "blah",
    ///                     "label": "blah"
    ///                 }
    ///                 "propositions": [               //  `propositions` data is an echo back of what was originally provided by XAS
    ///                     {
    ///                         "id": "fe47f125-dc8f-454f-b4e8-cf462d65eb67",
    ///                         "scope": "mobileapp://com.adobe.MessagingDemoApp",
    ///                         "scopeDetails": {
    ///                             "activity": {
    ///                                 "id": "<campaignId:packageId>"
    ///                             },
    ///                             "correlationID": "d7e644d7-9312-4d7b-8b52-7fa08ce5eccf",
    ///                             "characteristics": {
    ///                                 "cjmEventToken": "aCm/+7TFk4ojIuGQc+N842qipfsIHvVzTQxHolz2IpTMromRrB5ztP5VMxjHbs7c6qPG9UF4rvQTJZniWgqbOw=="
    ///                             }
    ///                         }
    ///                     }
    ///                 ]
    ///             }
    ///         }
    ///     }
    /// }

    /// Sends a proposition interaction to the customer's experience event dataset.
    ///
    /// If the message does not contain `scopeDetails`, required for properly tracking in AJO, this method will return as a no-op.
    ///
    /// - Parameters:
    ///   - eventType: type of event corresponding to this interaction
    ///   - interaction: a `String` describing the interaction
    ///   - message: the `Message` for which the interaction should be recorded
    func sendPropositionInteraction(withEventType eventType: MessagingEdgeEventType, andInteraction interaction: String?, forMessage message: Message) {
        guard let propInfo = message.propositionInfo, !propInfo.scopeDetails.isEmpty else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to send a proposition interaction - `scopeDetails` were not found for message (\(message.id)).")
            return
        }

        let propositions: [[String: Any]] = [
            [
                MessagingConstants.XDM.IAM.Key.ID: propInfo.id,
                MessagingConstants.XDM.IAM.Key.SCOPE: propInfo.scope,
                MessagingConstants.XDM.IAM.Key.SCOPE_DETAILS: propInfo.scopeDetails.asDictionary() ?? [:]
            ]
        ]

        let propositionEventType: [String: Int] = [
            eventType.propositionEventType: 1
        ]

        var decisioning: [String: Any] = [
            MessagingConstants.XDM.IAM.Key.PROPOSITION_EVENT_TYPE: propositionEventType,
            MessagingConstants.XDM.IAM.Key.PROPOSITIONS: propositions
        ]

        // only add `propositionAction` data if this is an interact event
        if eventType == .inappInteract {
            let propositionAction: [String: String] = [
                MessagingConstants.XDM.IAM.Key.ID: interaction ?? "",
                MessagingConstants.XDM.IAM.Key.LABEL: interaction ?? ""
            ]
            decisioning[MessagingConstants.XDM.IAM.Key.PROPOSITION_ACTION] = propositionAction
        }

        let experience: [String: Any] = [
            MessagingConstants.XDM.IAM.Key.DECISIONING: decisioning
        ]

        let xdm: [String: Any] = [
            MessagingConstants.XDM.Key.EVENT_TYPE: eventType.toString(),
            MessagingConstants.XDM.AdobeKeys.EXPERIENCE: experience
        ]

        // iam dictionary used for event history
        let iamHistory: [String: String] = [
            MessagingConstants.Event.History.Keys.EVENT_TYPE: eventType.propositionEventType,
            MessagingConstants.Event.History.Keys.MESSAGE_ID: propInfo.activityId,
            MessagingConstants.Event.History.Keys.TRACKING_ACTION: interaction ?? ""
        ]

        let mask = [
            MessagingConstants.Event.History.Mask.EVENT_TYPE,
            MessagingConstants.Event.History.Mask.MESSAGE_ID,
            MessagingConstants.Event.History.Mask.TRACKING_ACTION
        ]

        let xdmEventData: [String: Any] = [
            MessagingConstants.XDM.Key.XDM: xdm,
            MessagingConstants.Event.Data.Key.IAM_HISTORY: iamHistory
        ]

        // Creating xdm edge event with request content source type
        let event = Event(name: MessagingConstants.Event.Name.MESSAGE_INTERACTION,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: xdmEventData,
                          mask: mask)
        dispatch(event: event)
    }
}
