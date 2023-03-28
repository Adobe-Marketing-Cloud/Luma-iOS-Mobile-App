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
import AEPServices

/**
 An  extension for URL class to parse the URL and return a dictionary with key value pairs from the query string
 The query values will be URL decoded when they are stored in the output dictionary.
 */
extension URL {
    
    private typealias SOCKET_URL_KEYS = AssuranceConstants.SocketURLKeys
    
    /**
     A computed variable that returns the dictionary of available query string and value for this URL
     */
    var params: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }
        var dict: [String: String] = [:]
        for item in queryItems {
            if let queryValue = item.value {
                dict[item.name] = queryValue
            }
        }
        return dict
    }
    
    ///
    /// Checks that the URL is safe and no JS is being injected maliciously
    /// A safe URL passes the following criteria:
    ///     1. The `host/env` must be a valid `AssuranceEnvironment` type
    ///     2. The `token` param must be 4 integers in string format
    ///     3. The `sessionID` must be valid UUID with hyphens
    ///     4. The `clientID` must be a valid UUID with hyphens
    ///     5. The `orgID` must end with "@AdobeOrg"
    /// - Returns: True if the URL is safe
    var isSafe: Bool {
        let LOG_TAG = "Assurance URL Parser"
        
        guard let _ = self.env else {
            Log.error(label: LOG_TAG, "Socket url validation failed, malformed env parameter found.")
            return false
        }
        
        for (key, value) in self.params {
            switch key {
            case SOCKET_URL_KEYS.SESSION_ID_KEY:
                if !validate(sessionID: value) {
                    Log.error(label: LOG_TAG, "Socket url validation failed, malformed sessionID parameter found.")
                    return false
                }
            case SOCKET_URL_KEYS.CLIENT_ID_KEY:
                if !validate(clientID: value) {
                    Log.error(label: LOG_TAG, "Socket url validation failed, malformed clientID parameter found.")
                    return false
                }
            case SOCKET_URL_KEYS.ORG_ID_KEY:
                if !validate(orgID: value) {
                    Log.error(label: LOG_TAG, "Socket url validation failed, malformed orgID parameter found.")
                    return false
                }
            case SOCKET_URL_KEYS.TOKEN_KEY:
                if !validate(token: value) {
                    Log.error(label: LOG_TAG, "Socket url validation failed, malformed token parameter found.")
                    return false
                }
            default:
                Log.error(label: LOG_TAG, "Socket url validation failed, extra parameter(s) found.")
                return false
            }
        }
        
        return true
    }
    
    ///
    /// The AssuranceEnvironment for the URL, nil if there is no host in the URL
    ///
    var env: AssuranceEnvironment? {
        guard let host = host else {
            return nil
        }
        
        guard let connectString = host.split(separator: ".").first else {
            return .prod
        }

        if connectString.split(separator: "-").indices.contains(1) {
            let environmentString = connectString.split(separator: "-")[1]
            return AssuranceEnvironment(envString: String(environmentString))
        }
        return .prod
    }
    
    ///
    /// A safe sessionID is a valid UUID
    /// - Parameter sessionID as a `String`
    /// - Returns: true if the sessionID is safe
    private func validate(sessionID: String) -> Bool {
        guard UUID(uuidString: sessionID) != nil else {
            return false
        }
        
        return true
    }
    
    ///
    /// A safe clientID is a valid UUID
    /// - Parameter clientID as a `String`
    /// - Returns: true if the clientID is safe
    ///
    private func validate(clientID: String) -> Bool {
        guard UUID(uuidString: clientID) != nil else {
            return false
        }
        
        return true
    }
    
    ///
    /// A valid token is 4 digit integer in string format
    /// - Parameter token as a `String`
    /// - Returns: true if the token is safe
    ///
    private func validate(token: String) -> Bool {
        guard token.count == 4, Int(token) != nil else {
            return false
        }
        
        return true
    }
    
    ///
    /// A valid orgID ends with @AdobeOrg
    ///
    private func validate(orgID: String) -> Bool {
        let suffix = "@AdobeOrg"
        if orgID.hasSuffix(suffix) {
            return true
        } else {
            return false
        }
    }
}
