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
import UserNotifications

@objc public extension Messaging {

    /// Sends the push notification interactions as an experience event to Adobe Experience Edge.
    /// - Parameters:
    ///   - response: UNNotificationResponse object which contains the payload and xdm informations.
    ///   - applicationOpened: Boolean values denoting whether the application was opened when notification was clicked
    ///   - customActionId: String value of the custom action (e.g button id on the notification) which was clicked.
    @objc(handleNotificationResponse:applicationOpened:withCustomActionId:)
    static func handleNotificationResponse(_ response: UNNotificationResponse, applicationOpened: Bool, customActionId: String?) {
        let notificationRequest = response.notification.request
        let xdm = notificationRequest.content.userInfo[MessagingConstants.AdobeTrackingKeys._XDM] as? [String: Any]
        // Checking if the message has xdm key
        if xdm == nil {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to track push notification interaction. XDM specific fields are missing.")
        }

        let messageId = notificationRequest.identifier
        if messageId.isEmpty {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to track push notification interaction, Message Id is invalid in the response.")
            return
        }

        // Creating event data with tracking informations
        var eventData: [String: Any] = [MessagingConstants.EventDataKeys.MESSAGE_ID: messageId,
                                        MessagingConstants.EventDataKeys.APPLICATION_OPENED: applicationOpened,
                                        MessagingConstants.EventDataKeys.ADOBE_XDM: xdm ?? [:]] // If xdm data is nil we use empty dictionary
        if customActionId == nil {
            eventData[MessagingConstants.EventDataKeys.EVENT_TYPE] = MessagingConstants.EventDataValue.PUSH_TRACKING_APPLICATION_OPENED
        } else {
            eventData[MessagingConstants.EventDataKeys.EVENT_TYPE] = MessagingConstants.EventDataValue.PUSH_TRACKING_CUSTOM_ACTION
            eventData[MessagingConstants.EventDataKeys.ACTION_ID] = customActionId
        }

        let event = Event(name: MessagingConstants.EventName.PUSH_NOTIFICATION_INTERACTION,
                          type: MessagingConstants.EventType.messaging,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event)
    }
}
