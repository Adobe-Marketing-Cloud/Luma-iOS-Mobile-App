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

struct PropositionPayload: Codable {
    var propositionInfo: PropositionInfo
    var items: [PayloadItem]

    enum CodingKeys: String, CodingKey {
        case id
        case scope
        case scopeDetails
        case items
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        let scope = try values.decode(String.self, forKey: .scope)
        let scopeDetails = try values.decode([String: AnyCodable].self, forKey: .scopeDetails)

        propositionInfo = PropositionInfo(id: id, scope: scope, scopeDetails: scopeDetails)
        items = try values.decode([PayloadItem].self, forKey: .items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(propositionInfo.id, forKey: .id)
        try container.encode(propositionInfo.scope, forKey: .scope)
        try container.encode(propositionInfo.scopeDetails, forKey: .scopeDetails)
        try container.encode(items, forKey: .items)
    }
    
    /// internal use only for testing
    init(propositionInfo: PropositionInfo, items: [PayloadItem]) {
        self.propositionInfo = propositionInfo
        self.items = items
    }
}
