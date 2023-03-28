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

import AEPServices
import Foundation

extension String {
    /// Converts a json string into dictionary object.
    ///
    /// - Parameters:
    ///   - jsonString: json String that needs to be converted to a dictionary
    /// - Returns: A  dictionary representation of the string. Returns `nil` if the json serialization of the string fails.
    func toJsonDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                Log.debug(label: MessagingConstants.LOG_TAG, "Unexpected error occurred while converting string \(self) to dictionary: Error -  \(error).")
                return nil
            }
        }
        return nil
    }
}
