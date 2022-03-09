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
import Foundation

extension Event {
    /// Returns true if this event is a generic identity request content event
    var isGenericIdentityRequestContentEvent: Bool {
        return type == EventType.genericIdentity && source == EventSource.requestContent
    }

    var token: String? {
        return data?[MessagingConstants.EventDataKeys.PUSH_IDENTIFIER] as? String
    }

    var eventType: String? {
        return data?[MessagingConstants.EventDataKeys.EVENT_TYPE] as? String
    }

    var messagingId: String? {
        return data?[MessagingConstants.EventDataKeys.MESSAGE_ID] as? String
    }

    var actionId: String? {
        return data?[MessagingConstants.EventDataKeys.ACTION_ID] as? String
    }

    var applicationOpened: Bool {
        return data?[MessagingConstants.EventDataKeys.APPLICATION_OPENED] as? Bool ?? false
    }

    var mixins: [String: Any]? {
        return adobeXdm?[MessagingConstants.AdobeTrackingKeys.MIXINS] as? [String: Any]
    }

    var cjm: [String: Any]? {
        return adobeXdm?[MessagingConstants.AdobeTrackingKeys.CJM] as? [String: Any]
    }

    var adobeXdm: [String: Any]? {
        return data?[MessagingConstants.EventDataKeys.ADOBE_XDM] as? [String: Any]
    }

    var isMessagingRequestContentEvent: Bool {
        return type == MessagingConstants.EventType.messaging && source == EventSource.requestContent
    }
}
