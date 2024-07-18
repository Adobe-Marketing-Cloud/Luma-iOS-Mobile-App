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

/// Representation of an assurance server environment to which a session attempts to connect.
///
/// Following example assists on how to use the `AssuranceEnvironment` enum
///
/// From the assurance deeplink URL extract the environment query parameter and create an `AssuranceEnvironment` variable
/// Stage -  griffon://?adb_validation_sessionid=someId&env=stage -> AssuranceEnvironment.stage
/// Prod  -   griffon://?adb_validation_sessionid=someId -> AssuranceEnvironment.prod  (empty value or no value defaults to prod)
///
/// And use the AssuranceEnvironment.urlformat to prepare the host for socket connection
/// Staging : wss://connect-stage
/// Prod : wss://connect
enum AssuranceEnvironment: String {
    case prod = ""
    case qa = "qa"
    case stage = "stage"
    case dev = "dev"

    /// A String that represents the environment URL format to be appending to the host of the url
    /// An empty string is provided for `PRODUCTION` environment
    var urlFormat: String {
        switch self {
        case .prod:
            return AssuranceEnvironmentURLFormat.PRODUCTION
        case .qa:
            return AssuranceEnvironmentURLFormat.QA
        case .stage:
            return AssuranceEnvironmentURLFormat.STAGE
        case .dev:
            return AssuranceEnvironmentURLFormat.DEV
        }
    }
    /// Initializer that converts a `String` to its respective `AssuranceEnvironment`
    /// If `envString` is not a valid `AssuranceEnvironment`, calling this method will return `AssuranceEnvironment.prod`
    /// - Parameter envString: a `String` representation of a `AssuranceEnvironment`
    /// - Returns: a `AssuranceEnvironment` representing the passed-in `String`
    init(envString: String) {
        self = AssuranceEnvironment(rawValue: envString) ?? .prod
    }

    enum AssuranceEnvironmentURLFormat {
        static let PRODUCTION = ""
        static let QA = "-qa"
        static let STAGE = "-stage"
        static let DEV = "-dev"
    }

}
