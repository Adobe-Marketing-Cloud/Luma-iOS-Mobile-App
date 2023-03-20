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

enum ConsentConstants {
    static let EXTENSION_NAME = "com.adobe.edge.consent"
    static let FRIENDLY_NAME = "Consent"
    static let EXTENSION_VERSION = "1.0.1"
    static let LOG_TAG = FRIENDLY_NAME

    enum EventDataKeys {
        static let CONSENTS = "consents"
        static let METADATA = "metadata"
        static let TIME = "time"
        static let PAYLOAD = "payload"
    }

    enum EventNames {
        static let CONSENT_UPDATE_REQUEST = "Consent Update Request"
        static let EDGE_CONSENT_UPDATE = "Edge Consent Update Request"
        static let CONSENT_PREFERENCES_UPDATED = "Consent Preferences Updated"
        static let GET_CONSENTS_REQUEST = "Get Consents Request"
        static let GET_CONSENTS_RESPONSE = "Get Consents Response"
    }

    enum EventSource {
        static let CONSENT_PREFERENCES = "consent:preferences"
    }

    enum DataStoreKeys {
        static let CONSENT_PREFERENCES = "consent.preferences"
    }

    enum SharedState {
        static let STATE_OWNER = "stateowner"

        enum Configuration {
            static let STATE_OWNER_NAME = "com.adobe.module.configuration"
            static let CONSENT_DEFAULT = "consent.default"
        }
    }
}
