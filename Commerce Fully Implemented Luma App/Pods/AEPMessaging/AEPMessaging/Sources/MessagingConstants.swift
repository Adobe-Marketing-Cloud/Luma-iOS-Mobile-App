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

    static let EXTENSION_VERSION = "1.1.3"
    static let FRIENDLY_NAME = "Messaging"
    static let RULES_ENGINE_NAME = EXTENSION_NAME + ".rulesengine"
    static let THIRTY_DAYS_IN_SECONDS = TimeInterval(60 * 60 * 24 * 30)

    enum Caches {
        static let CACHE_NAME = "com.adobe.messaging.cache"
        static let MESSAGES = "messages"
        static let PROPOSITIONS = "propositions"
        static let MESSAGES_DELIMITER = "||"
        static let PATH = "PATH"
    }

    enum ConsequenceTypes {
        static let IN_APP_MESSAGE = "cjmiam"
    }

    enum Event {
        enum Name {
            static let MESSAGE_INTERACTION = "Messaging interaction event"
            static let PUSH_NOTIFICATION_INTERACTION = "Push notification interaction event"
            static let PUSH_PROFILE_EDGE = "Push notification profile edge event"
            static let PUSH_TRACKING_EDGE = "Push tracking edge event"
            static let REFRESH_MESSAGES = "Refresh in-app messages"
            static let RETRIEVE_MESSAGE_DEFINITIONS = "Retrieve message definitions"
        }

        enum Source {
            static let PERSONALIZATION_DECISIONS = "personalization:decisions"
        }

        enum EventType {
            static let messaging = "com.adobe.eventType.messaging"
        }

        enum Data {
            enum Key {
                static let PUSH_IDENTIFIER = "pushidentifier"
                static let EVENT_TYPE = "eventType"
                static let MESSAGE_ID = "id"
                static let APPLICATION_OPENED = "applicationOpened"
                static let ACTION_ID = "actionId"
                static let REFRESH_MESSAGES = "refreshmessages"
                static let ADOBE_XDM = "adobe_xdm"
                static let REQUEST_EVENT_ID = "requestEventId"
                static let IAM_HISTORY = "iam"

                static let TRIGGERED_CONSEQUENCE = "triggeredconsequence"
                static let ID = "id"
                static let DETAIL = "detail"
                static let TYPE = "type"
                static let SOURCE = "source"

                // In-App Messages
                enum IAM {
                    static let ID = "id"
                    static let TEMPLATE = "template"
                    static let HTML = "html"
                    static let REMOTE_ASSETS = "remoteAssets"
                    static let TITLE = "title"
                    static let CONTENT = "content"
                    static let CONFIRM = "confirm"
                    static let CANCEL = "cancel"
                    static let URL = "url"
                    static let WAIT = "wait"
                    static let DATE = "date"
                    static let DEEPLINK = "adb_deeplink"
                    static let USER_DATA = "userData"
                    static let CATEGORY = "category"
                    static let SOUND = "sound"

                    // layout keys
                    static let MOBILE_PARAMETERS = "mobileParameters"
                    static let SCHEMA_VERSION = "schemaVersion"
                    static let WIDTH = "width"
                    static let HEIGHT = "height"
                    static let VERTICAL_ALIGN = "verticalAlign"
                    static let VERTICAL_INSET = "verticalInset"
                    static let HORIZONTAL_ALIGN = "horizontalAlign"
                    static let HORIZONTAL_INSET = "horizontalInset"
                    static let UI_TAKEOVER = "uiTakeover"
                    static let DISPLAY_ANIMATION = "displayAnimation"
                    static let DISMISS_ANIMATION = "dismissAnimation"
                    static let GESTURES = "gestures"
                    static let BODY = "body"
                    static let BACKDROP_COLOR = "backdropColor"
                    static let BACKDROP_OPACITY = "backdropOpacity"
                    static let CORNER_RADIUS = "cornerRadius"
                }

                enum Personalization {
                    static let PAYLOAD = "payload"
                    static let CORRELATION_ID = "correlationID"
                    static let ACTIVITY = "activity"
                    static let ID = "id"
                }
            }

            enum Values {
                enum IAM {
                    // template values
                    static let FULLSCREEN = "fullscreen"
                    static let LOCAL = "local"

                    // layout values
                    static let SWIPE_UP = "swipeUp"
                    static let SWIPE_DOWN = "swipeDown"
                    static let SWIPE_LEFT = "swipeLeft"
                    static let SWIPE_RIGHT = "swipeRight"
                    static let TAP_BACKGROUND = "tapBackground"
                }
            }
        }

        enum History {
            enum Keys {
                // these kvps are embedded in an object named `iam`,
                // so the mask path to them is e.g. "iam.eventType"
                static let EVENT_TYPE = "eventType"
                static let MESSAGE_ID = "id"
                static let TRACKING_ACTION = "action"
            }
            enum Mask {
                static let EVENT_TYPE = "iam.eventType"
                static let MESSAGE_ID = "iam.id"
                static let TRACKING_ACTION = "iam.action"
            }
        }
    }

    enum IAM {
        enum HTML {
            static let SCHEME = "adbinapp"
            static let INTERACTION = "interaction"
            static let DISMISS = "dismiss"
            static let LINK = "link"
            static let ANIMATE = "animate"
        }

        enum Plist {
            static let ACTIVITY_ID = "MESSAGING_ACTIVITY_ID"
            static let PLACEMENT_ID = "MESSAGING_PLACEMENT_ID"
        }
    }

    enum XDM {
        enum AdobeKeys {
            static let _XDM = "_xdm"
            static let CJM = "cjm"
            static let MIXINS = "mixins"
            static let EXPERIENCE = "_experience"
            static let CUSTOMER_JOURNEY_MANAGEMENT = "customerJourneyManagement"
            static let MESSAGE_EXECUTION = "messageExecution"
            static let MESSAGE_EXECUTION_ID = "messageExecutionID"
            static let APPLICATION = "application"
            static let LAUNCHES = "launches"
            static let LAUNCHES_VALUE = "value"
            static let MESSAGE_PROFILE_JSON = "{\n   \"messageProfile\":" +
                "{\n      \"channel\": {\n         \"_id\": \"https://ns.adobe.com/xdm/channels/push\"\n      }\n   }" +
                ",\n   \"pushChannelContext\": {\n      \"platform\": \"apns\"\n   }\n}"
        }

        enum Key {
            static let ADOBE_XDM = "adobe_xdm"
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

        enum IAM {
            static let SURFACE_BASE = "mobileapp://"

            enum EventType {
                static let TRIGGER = "decisioning.propositionTrigger"
                static let DISPLAY = "decisioning.propositionDisplay"
                static let INTERACT = "decisioning.propositionInteract"
                static let DISMISS = "decisioning.propositionDismiss"
                static let PERSONALIZATION_REQUEST = "personalization.request"
            }

            enum PropositionEventType {
                static let TRIGGER = "trigger"
                static let DISPLAY = "display"
                static let INTERACT = "interact"
                static let DISMISS = "dismiss"
            }

            enum Key {
                static let PERSONALIZATION = "personalization"
                static let QUERY = "query"
                static let SURFACES = "surfaces"
                static let DECISIONING = "decisioning"
                static let PROPOSITION_ACTION = "propositionAction"
                static let LABEL = "label"
                static let PROPOSITION_EVENT_TYPE = "propositionEventType"
                static let PROPOSITIONS = "propositions"
                static let ID = "id"
                static let SCOPE = "scope"
                static let SCOPE_DETAILS = "scopeDetails"
                static let CHARACTERISTICS = "characteristics"
                static let CJM_XDM = "cjmXdm"
                static let IN_APP_MESSAGE_TRACKING = "inappMessageTracking"
                static let ACTION = "action"
            }

            enum Value {
                static let TRIGGERED = "triggered"
                static let DISPLAYED = "displayed"
                static let CLICKED = "clicked"
                static let DISMISSED = "dismissed"
                static let EMPTY_CONTENT = "{}"
            }
        }

        enum Push {
            static let PUSH_NOTIFICATION_DETAILS = "pushNotificationDetails"
            static let APP_ID = "appID"
            static let TOKEN = "token"
            static let PLATFORM = "platform"
            static let DENYLISTED = "denylisted"
            static let IDENTITY = "identity"
            static let NAMESPACE = "namespace"
            static let CODE = "code"
            static let ID = "id"

            enum EventType {
                static let APPLICATION_OPENED = "pushTracking.applicationOpened"
                static let CUSTOM_ACTION = "pushTracking.customAction"
            }

            enum Value {
                static let ECID = "ECID"
                static let APNS = "apns"
                static let APNS_SANDBOX = "apnsSandbox"
            }
        }
    }

    enum SharedState {
        static let stateOwner = "stateowner"

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
