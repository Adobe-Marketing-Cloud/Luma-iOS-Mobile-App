/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPServices
import Foundation

struct PropositionInfo: Codable {
    var id: String
    var scope: String
    var scopeDetails: [String: AnyCodable]
}

extension PropositionInfo {
    var correlationId: String {
        return scopeDetails[MessagingConstants.Event.Data.Key.Personalization.CORRELATION_ID]?.stringValue ?? ""
    }

    var activityId: String {
        guard let activity = scopeDetails[MessagingConstants.Event.Data.Key.Personalization.ACTIVITY]?.dictionaryValue else {
            return ""
        }
        return activity[MessagingConstants.Event.Data.Key.Personalization.ID] as? String ?? ""
    }
}
