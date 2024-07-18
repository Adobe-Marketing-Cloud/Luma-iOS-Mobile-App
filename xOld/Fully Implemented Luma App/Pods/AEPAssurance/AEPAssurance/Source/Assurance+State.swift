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
import Foundation

extension Assurance {

    /// Call this function to create a new shared state for Assurance
    /// Important - An empty shared state is created if sessionId is not available
    func shareState() {
        runtime.createSharedState(data: getSharedStateData() ?? [:], event: nil)
    }

    /// Call this function to empty the latest Assurance shared state
    func clearState() {
        runtime.createSharedState(data: [:], event: nil)
    }

    /// Prepares the shared state data for the Assurance Extension
    /// A valid shared state contains:
    /// - sessionid
    /// - clientid
    /// - integrationid
    ///
    /// - Returns: a dictionary  representing the current shared state data
    private func getSharedStateData() -> [String: String]? {
        // do not share shared state if the sessionId is unavailable
        guard let sessionId = sessionId else {
            return nil
        }

        var shareStateData: [String: String] = [:]
        shareStateData[AssuranceConstants.SharedStateKeys.CLIENT_ID] = clientID
        shareStateData[AssuranceConstants.SharedStateKeys.SESSION_ID] = sessionId
        shareStateData[AssuranceConstants.SharedStateKeys.INTEGRATION_ID] = sessionId + "|" + clientID
        return shareStateData
    }

}
