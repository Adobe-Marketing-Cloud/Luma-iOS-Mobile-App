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

enum AssuranceConstants {
    static let EXTENSION_NAME = "com.adobe.assurance"
    static let FRIENDLY_NAME = "Assurance"
    static let EXTENSION_VERSION = "3.1.0"
    static let LOG_TAG = FRIENDLY_NAME
    static let DEFAULT_ENVIRONMENT = AssuranceEnvironment.prod

    static let BASE_SOCKET_URL = "wss://connect%@.griffon.adobe.com/client/v1?sessionId=%@&token=%@&orgId=%@&clientId=%@"
    static let QUICK_CONNECT_BASE_URL = "https://device.griffon.adobe.com/device"
    static let SHUTDOWN_TIME = TimeInterval(5)
    
    enum SocketURLKeys {
        static let SESSION_ID_KEY = "sessionId"
        static let TOKEN_KEY = "token"
        static let CLIENT_ID_KEY = "clientId"
        static let ORG_ID_KEY = "orgId"
    }

    enum Deeplink {
        static let SESSIONID_KEY = "adb_validation_sessionid"
        static let ENVIRONMENT_KEY = "env"
    }

    enum SharedStateName {
        static let CONFIGURATION = "com.adobe.module.configuration"
        static let EVENT_HUB = "com.adobe.module.eventhub"
    }

    enum Vendor {
        static let MOBILE = "com.adobe.griffon.mobile"
        static let SDK = "com.adobe.marketing.mobile.sdk"
    }

    enum SDKEventName {
        static let SHARED_STATE_CHANGE = "Shared state change"
        static let XDM_SHARED_STATE_CHANGE = "Shared state change (XDM)"
    }

    enum SDKEventType {
        static let ASSURANCE = "com.adobe.eventType.assurance"
    }

    enum PluginFakeEvent {
        static let NAME = "eventName"
        static let TYPE = "eventType"
        static let SOURCE = "eventSource"
        static let DATA = "eventData"
    }

    // todo verify the impact of making these keys AEPExtensionEvent*
    enum ACPExtensionEventKey {
        static let NAME    = "ACPExtensionEventName"
        static let TYPE    = "ACPExtensionEventType"
        static let SOURCE  = "ACPExtensionEventSource"
        static let DATA    = "ACPExtensionEventData"
        static let TIMESTAMP = "ACPExtensionEventTimestamp"
        static let NUMBER = "ACPExtensionEventNumber"
        static let UNIQUE_IDENTIFIER = "ACPExtensionEventUniqueIdentifier"
        static let RESPONSE_IDENTIFIER = "ACPExtensionEventResponseIdentifier" // todo new key introduced : convey to UI team
    }

    enum EventDataKey {
        static let START_SESSION_URL = "startSessionURL"
        static let CONFIG_ORG_ID = "experienceCloud.org"
        static let SHARED_STATE_OWNER = "stateowner"
        static let EXTENSIONS = "extensions"
        static let FRIENDLY_NAME = "friendlyName"
        static let QUICK_CONNECT = "quickConnect"
    }

    enum DataStoreKeys {
        static let SESSION_ID = "assurance.session.Id"
        static let CLIENT_ID = "assurance.client.Id"
        static let ENVIRONMENT = "assurance.environment"
        static let SOCKETURL = "assurance.socketurl"
        static let CONFIG_MODIFIED_KEYS = "assurance.control.modifiedConfigKeys"
    }

    enum SharedStateKeys {
        static let CLIENT_ID = "sessionid"
        static let SESSION_ID = "clientid"
        static let INTEGRATION_ID = "integrationid"
    }

    enum EventType {
        static let GENERIC = "generic"
        static let LOG = "log"
        static let CONTROL = "control"
        static let CLIENT = "client"
        static let BLOB = "blob"
    }

    enum PayloadKey {
        static let SHARED_STATE_DATA = "state.data"
        static let XDM_SHARED_STATE_DATA = "xdm.state.data"
        static let METADATA = "metadata"
        static let TYPE = "type"
        static let DETAIL = "detail"
    }

    enum HTMLURLPath {
        static let CANCEL   = "cancel"
        static let CONFIRM  = "confirm"
        static let DISCONNECT = "disconnect"
    }

    enum ClientInfoKeys {
        static let TYPE = "type"
        static let VERSION = "version"
        static let DEVICE_INFO = "deviceInfo"
        static let APP_SETTINGS = "appSettings"
    }

    enum CommandType {
        static let START_EVENT_FORWARDING = "startEventForwarding"
        static let CONFIG_UPDATE = "configUpdate"
        static let FAKE_EVENT = "fakeEvent"
        static let SCREENSHOT = "screenshot"
        static let LOG_FORWARDING = "logForwarding"
        static let WILDCARD = "wildcard"
    }

    enum SocketCloseCode {
        static let NORMAL_CLOSURE = 1000
        static let ABNORMAL_CLOSURE = 1006
        static let ORG_MISMATCH = 4900
        static let CONNECTION_LIMIT = 4901
        static let EVENTS_LIMIT = 4902
        static let DELETED_SESSION = 4903
        static let CLIENT_ERROR = 4400
    }

    enum LogForwarding {
        static let LOG_LINE = "logline"
        static let ENABLE = "enable"
    }

    enum Places {
        enum EventName {
            static let REQUEST_NEARBY_POI = "requestgetnearbyplaces"
            static let REQUEST_RESET = "requestreset"
            static let RESPONSE_REGION_EVENT = "responseprocessregionevent"
            static let RESPONSE_NEARBY_POI_EVENT = "responsegetnearbyplaces"
        }

        enum EventDataKeys {
            static let COUNT = "count"
            static let LATITUDE = "latitude"
            static let LONGITUDE = "longitude"
            static let REGION_NAME = "regionname"
            static let USER_IS_WITHIN = "useriswithin"
            static let TRIGGERING_REGION = "triggeringregion"
            static let REGION_EVENT_TYPE = "regioneventtype"
            static let NEARBY_POI = "nearbypois"
        }
    }

    enum AssuranceEvent {
        /// The maximum size of an event that can get through the socket is 32KB.
        /// The factor 0.75 is introduced to accommodate blowing up of size due to the mandatory base64 encoding of AssuranceEvent before sending through the socket.
        static let SIZE_LIMIT = (Int) ((32 * 1024) * 0.75)
        
        enum Name {
            static let DEEPLINK_START_SESSION = "Assurance Start Session"
            static let QUICKCONNECT_START_SESSION = "Assurance Quick Connect Start Session"
        }
        
        enum PayloadKey {
            static let CHUNK_DATA = "chunkData"
        }

        enum MetadataKey {
            static let CHUNK_ID = "chunkId"
            static let CHUNK_SEQUENCE = "chunkSequenceNumber"
            static let CHUNK_TOTAL = "chunkTotal"
        }
    }

    enum QuickConnect {
        static let SHAKE_NOTIFICATION_KEY = "AdobeAssuranceShakeDetector"
        static let KEY_ORGID = "orgId"
        static let KEY_DEVICE_NAME = "deviceName"
        static let KEY_CLIENT_ID = "clientId"

        enum QuickConnectView {
            static let HEADER_HEIGHT = 110.0
            static let HEADER_LABEL_HEIGHT = 60.0
            static let HEADER_LABEL_BOTTOM_MARGIN = -10.0

            static let DESCRIPTION_TEXTVIEW_TOP_MARGIN = 30.0
            static let DESCRIPTION_TEXTVIEW_HEIGHT = 50.0

            static let CONNECTION_IMAGE_TOP_MARGIN = 10.0
            static let CONNECTION_IMAGE_HEIGHT = 70.0
            
            static let ERROR_TITLE_TOP_MARGIN = 10.0
            static let ERROR_TITLE_HEIGHT = 30.0
            
            static let ERROR_DESCRIPTION_TOP_MARGIN = 10.0
            static let ERROR_DESCRIPTION_HEIGHT = 140.0

            static let BUTTON_HOLDER_TOP_MARGIN = 30.0
            static let BUTTON_HOLDER_HEIGHT = 60.0

            static let ADOBE_LOGO_IMAGE_BOTTOM_MARGIN = -10.0
            static let ADOBE_LOGO_IMAGE_HEIGHT = 20.0

            static let CANCEL_BUTTON_TOP_MARGIN = 10
            static let CANCEL_BUTTON_HEIGHT = 45.0
            static let BUTTON_CORNER_RADIUS = 22.5

            static let BUTTON_FONT_SIZE = 17.0
        }
    }

    enum Network {
        static let CONNECTION_TIMEOUT = TimeInterval(10)
        static let READ_TIMEOUT = TimeInterval(10)
    }


}
