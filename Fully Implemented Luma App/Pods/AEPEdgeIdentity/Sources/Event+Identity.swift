//
// Copyright 2022 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import AEPCore
import Foundation

extension Event {
    /// Reads the url variables flag from the event data, returns false if not present
    var urlVariables: Bool {
        return data?[IdentityConstants.EventDataKeys.URL_VARIABLES] as? Bool ?? false
    }

    /// Reads the advertising ID from the event data
    ///
    /// Performs a sanitization of values, converting `nil`, `""`, and `IdentityConstants.Default.ZERO_ADVERTISING_ID` into `""`
    /// Recommended to use `isAdIdEvent` check before using this value
    /// - Returns: the extracted AdId, or `nil` if the Event is not an AdId event,
    var adId: String {
        // Sanity check; Sanitize `nil` String value
        guard let adId = data?[IdentityConstants.EventDataKeys.ADVERTISING_IDENTIFIER] as? String else {
            return ""
        }
        // Sanitize all-zero ID value
        if adId == IdentityConstants.Default.ZERO_ADVERTISING_ID {
            return ""
        }
        return adId
    }

    /// Checks if the Event is an AdId event, based on the presence of the `ADVERTISING_IDENTIFIER` key and corresponding `String` value type at the top level of `data`.
    ///
    /// Because the `Any` type anonymizes the original classes of nil values, all checks against optional types pass if the actual value is `nil`.
    /// Currently, only non-optional String values trigger updating the AdID as the value is compared to the non-optional `String` class
    var isAdIdEvent: Bool {
        return data?.keys.contains(IdentityConstants.EventDataKeys.ADVERTISING_IDENTIFIER) ?? false && data?[IdentityConstants.EventDataKeys.ADVERTISING_IDENTIFIER] is String
    }
}
