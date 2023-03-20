/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation

enum UserProfileConstants {
    static let EXTENSION_NAME = "com.adobe.module.userProfile"
    static let FRIENDLY_NAME = "UserProfile"
    static let EXTENSION_VERSION = "3.0.1"
    static let LOG_PREFIX = FRIENDLY_NAME
    static let DATASTORE_NAME = EXTENSION_NAME
    static let DATASTORE_KEY_ATTRIBUTES = "attributes"

    enum V5Migration {
        static let USER_PROFILE_KEY = "Adobe.ADBUserProfile.user_profile"
    }

    enum Configuration {
        static let NAME = "com.adobe.module.configuration"
    }

    enum UserProfile {
        static let EVENT_NAME_UPDATE_USER_PROFILE = "UserProfileUpdate"
        static let EVENT_NAME_GET_USER_PROFILE = "getUserAttributes"
        static let EVENT_NAME_REMOVE_USER_PROFILE = "RemoveUserProfiles"
        enum EventDataKeys {
            static let UPDATE_DATA = "userprofileupdatekey"
            static let REMOVE_DATA = "userprofileremovekeys"
            static let GET_DATA_ATTRIBUTES = "userprofilegetattributes"
            static let USERPROFILE_DATA = "userprofiledata"
            static let ERROR_RESPONSE = "errorresponse"
            static let ERROR_MESSAGE = "errormessagekey"
        }
    }

    enum RulesEngine {
        static let CONSEQUENCE_KEY_CSP = "csp"
        static let CONSEQUENCE_OPERATION_WRITE = "write"
        static let CONSEQUENCE_OPERATION_DELETE = "delete"
        enum EventDataKeys {
            static let TRIGGERED_CONSEQUENCE = "triggeredconsequence"
            static let ID = "id"
            static let DETAIL = "detail"
            static let TYPE = "type"
            static let DETAIL_KEY = "key"
            static let DETAIL_VALUE = "value"
            static let DETAIL_OPERATION = "operation"
        }
    }
}
