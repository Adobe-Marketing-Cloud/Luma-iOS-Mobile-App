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

import AEPServices
import Foundation

class AssuranceSessionDetails {

    typealias SOCKET_URL_KEYS = AssuranceConstants.SocketURLKeys
    
    /// A unique ID representing a session.
    let sessionId: String

    /// Environment to which the Assurance session connection is made.
    ///
    /// For developer use only.
    /// This environment has no co-relation with environment from Data Collection (Launch) configuration.
    let environment: AssuranceEnvironment

    /// A unique ID representing a client device.
    ///
    /// This Id is persisted for lifetime of the application.
    let clientID: String

    /// The 4 digit authentication code to connect to a session.
    ///
    /// token is obtained either via the pin code flow, or the quick connect flow.
    var token: String?

    /// A Unique ID representing the Adobe Org under which the Assurance session is created.
    var orgId: String?

    /// Initializer
    ///
    /// This init takes the minimum required details to initiate an Assurance session.
    /// - Parameters:
    ///  - sessionId:A string representing sessionId for a session
    ///  - clientId: A string representing  clientId
    ///  - environment: the AssuranceEnvironment
    init(sessionId: String, clientId: String, environment: AssuranceEnvironment = AssuranceEnvironment.prod, token: String? = nil, orgID: String? = nil) {
        self.sessionId = sessionId
        self.clientID = clientId
        self.environment = environment
        self.token = token
        self.orgId = orgID
    }

    /// Initializer
    ///
    /// This init takes the socket URL String that contains all the necessary details to connect to an Assurance session.
    ///
    /// - throws:`AssuranceSessionDetailBuilderError` with apt message if the socketURL
    ///           does not contain all the necessary session details
    ///
    /// - Parameters:
    ///    - socketURLString: The previously connected socketURLString
    init(withURLString socketURLString: String) throws {

        guard let socketURL = URL(string: socketURLString) else {
            throw AssuranceSessionDetailBuilderError(message: "Not a vaild URL")
        }

        guard let sessionId = socketURL.params[SOCKET_URL_KEYS.SESSION_ID_KEY] else {
            throw AssuranceSessionDetailBuilderError(message: "No SessionId")
        }

        guard let clientId = socketURL.params[SOCKET_URL_KEYS.CLIENT_ID_KEY] else {
            throw AssuranceSessionDetailBuilderError(message: "No ClientId")
        }

        guard let orgId = socketURL.params[SOCKET_URL_KEYS.ORG_ID_KEY] else {
            throw AssuranceSessionDetailBuilderError(message: "No OrgId")
        }

        guard let token = socketURL.params[SOCKET_URL_KEYS.TOKEN_KEY] else {
            throw AssuranceSessionDetailBuilderError(message: "No Token")
        }

        guard let host = socketURL.host else {
            throw AssuranceSessionDetailBuilderError(message: "URL has no host")
        }

        self.sessionId = sessionId
        self.clientID = clientId
        self.orgId = orgId
        self.token = token
        self.environment = AssuranceSessionDetails.readEnvironment(fromHost: host)
    }

    /// Retrieves the authenticated socket URL to make successful socket connection.
    /// - Returns: Success Result with URL if the session details contains all the necessary data
    ///            Failure Result with AssuranceSessionDetailAuthenticationError if any authentication parameters were missing.
    func getAuthenticatedSocketURL() -> Result<URL, AssuranceSessionDetailAuthenticationError> {
        guard let pin = token else {
            return .failure(.noPinCode)
        }

        guard let orgId = orgId else {
            return .failure(.noOrgId)
        }

        // wss://connect%@.griffon.adobe.com/client/v1?sessionId=%@&token=%@&orgId=%@&clientId=%@
        let socketURL = String(format: AssuranceConstants.BASE_SOCKET_URL,
                               environment.urlFormat,
                               sessionId,
                               pin,
                               orgId,
                               clientID)

        guard let url = URL(string: socketURL) else {
            return .failure(.invalidURL)
        }
        return .success(url)
    }

    /// Authenticate the session details with Pin and OrgId.
    ///
    /// Once authenticated use `getAuthenticatedSocketURL` function to retrieve the
    /// valid URL to make a successful assurance socket connection for the session.
    ///
    /// - Parameters:
    ///   - pinCode: The 4 digit authentication code obtained from input of pinCode screen.
    ///   - orgId: The Adobe OrgId obtained from DataCollection(Launch) UI configuration.
    func authenticate(withPIN pinCode: String, andOrgID orgId: String) {
        self.token = pinCode
        self.orgId = orgId
    }

    /// Retrieve the `AssuranceEnvironment` from the host of the URL.
    /// - Parameters:
    ///    - host: The host of the already connected socket URL
    /// - Returns:the `AssuranceEnvironment` obtained from the host
    private static func readEnvironment(fromHost host: String) -> AssuranceEnvironment {
        guard let connectString = host.split(separator: ".").first else {
            return .prod
        }

        if connectString.split(separator: "-").indices.contains(1) {
            let environmentString = connectString.split(separator: "-")[1]
            return AssuranceEnvironment(envString: String(environmentString))
        }
        return .prod
    }
}

struct AssuranceSessionDetailBuilderError: Error {
    let message: String
}

enum AssuranceSessionDetailAuthenticationError: Error {
    case noPinCode
    case noOrgId
    case invalidURL
}
