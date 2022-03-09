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

import Foundation

enum MessagingConstants {
    static let LOG_TAG = "Messaging"
    static let EXTENSION_NAME = "com.adobe.messaging"
    static let EXTENSION_VERSION = "1.0.0"
    static let FRIENDLY_NAME = "AEPMessaging"

    enum EventName {
        static let PUSH_NOTIFICATION_INTERACTION = "Push notification interaction event"
        static let PUSH_TRACKING_EDGE = "Push tracking edge event"
        static let PUSH_PROFILE_EDGE = "Push notification profile edge event"
    }

    enum EventType {
        static let messaging = "com.adobe.eventType.messaging"
    }

    enum EventDataKeys {
        static let PUSH_IDENTIFIER = "pushidentifier"
        static let EVENT_TYPE = "eventType"
        static let MESSAGE_ID = "id"
        static let APPLICATION_OPENED = "applicationOpened"
        static let ACTION_ID = "actionId"
        static let ADOBE_XDM = "adobe_xdm"
    }

    enum EventDataValue {
        static let PUSH_TRACKING_APPLICATION_OPENED = "pushTracking.applicationOpened"
        static let PUSH_TRACKING_CUSTOM_ACTION = "pushTracking.customAction"
    }

    enum AdobeTrackingKeys {
        static let _XDM = "_xdm"
        static let CJM = "cjm"
        static let MIXINS = "mixins"
        static let CUSTOMER_JOURNEY_MANAGEMENT = "customerJourneyManagement"
        static let EXPERIENCE = "_experience"
        static let APPLICATION = "application"
        static let LAUNCHES = "launches"
        static let LAUNCHES_VALUE = "value"
        static let MESSAGE_PROFILE_JSON = "{\n   \"messageProfile\":" +
            "{\n      \"channel\": {\n         \"_id\": \"https://ns.adobe.com/xdm/channels/push\"\n      }\n   }" +
            ",\n   \"pushChannelContext\": {\n      \"platform\": \"apns\"\n   }\n}"
    }

    enum XDMDataKeys {
        static let XDM = "xdm"
        static let META = "meta"
        static let COLLECT = "collect"
        static let DATASET_ID = "datasetId"
        static let ACTION_ID = "actionID"
        static let CUSTOM_ACTION = "customAction"
        static let PUSH_PROVIDER_MESSAGE_ID = "pushProviderMessageID"
        static let PUSH_PROVIDER = "pushProvider"
        static let EVENT_TYPE = "eventType"
        static let PUSH_NOTIFICATION_TRACKING = "pushNotificationTracking"
        static let DATA = "data"
    }

    enum PushNotificationDetails {
        // push
        static let PUSH_NOTIFICATION_DETAILS = "pushNotificationDetails"
        static let APP_ID = "appID"
        static let TOKEN = "token"
        static let PLATFORM = "platform"
        static let DENYLISTED = "denylisted"
        static let IDENTITY = "identity"
        static let NAMESPACE = "namespace"
        static let CODE = "code"
        static let ID = "id"

        enum JsonValues {
            static let ECID = "ECID"
            static let APNS = "apns"
            static let APNS_SANDBOX = "apnsSandbox"
        }
    }

    struct SharedState {
        static let STATE_OWNER = "stateowner"

        enum Messaging {
            static let PUSH_IDENTIFIER = "pushidentifier"
        }

        enum Configuration {
            static let NAME = "com.adobe.module.configuration"
            static let EXPERIENCE_CLOUD_ORG = "experienceCloud.org"

            // Messaging dataset ids
            static let EXPERIENCE_EVENT_DATASET = "messaging.eventDataset"

            // config for whether to useSandbox or not
            static let USE_SANDBOX = "messaging.useSandbox"
        }

        enum EdgeIdentity {
            static let NAME = "com.adobe.edge.identity"
            static let IDENTITY_MAP = "identityMap"
            static let ECID = "ECID"
            static let ID = "id"
        }
    }
}
