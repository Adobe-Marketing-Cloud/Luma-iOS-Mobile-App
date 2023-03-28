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

// todo later: For better clarity separate out into two enums .. socketError vs clientSideError for socket connection
enum AssuranceConnectionError: Error, Equatable {
    case genericError
    case noOrgId
    case noPincode
    case noURL
    case orgIDMismatch
    case connectionLimit
    case eventLimit
    case deletedSession
    case clientError
    case userCancelled
    case invalidURL(url: String)
    case invalidRequestBody
    case invalidResponseData
    case failedToRegisterDevice(statusCode: Int, responseMessage: String)
    case failedToGetDeviceStatus(statusCode: Int, responseMessage: String)
    case failedToDeleteDevice(statusCode: Int, responseMessage: String)

    var info: (name: String, description: String, shouldRetry: Bool) {
        switch self {
        case .genericError:
            return ("Connection Error",
                    "The connection may be failing due to a network issue or an incorrect PIN. Please verify internet connectivity or the PIN and try again.", true)
        case .noPincode:
            return ("HTML Error",
                    "Unable to extract the pincode entered.", true)
        case .noURL:
            return ("Socket Connection Error",
                    "Unable to form a valid socket URL for connection.", false)
        case .noOrgId:
            return (" Invalid Mobile SDK Configuration",
                    "The Experience Cloud organization identifier is unavailable. Ensure SDK configuration is setup correctly. See documentation for more detail.", false)
        case .orgIDMismatch:
            return ("Unauthorized Access",
                    "The Experience Cloud organization identifier does not match with that of the Assurance session. Ensure the right Experience Cloud organization is being used. See documentation for more detail.", false)
        case .connectionLimit:
            return ("Connection Limit Reached",
                    "You have reached the maximum number of connected device (50) allowed to a session.", false)
        case .eventLimit:
            return ("Event Limit Reached",
                    "You have reached the maximum number of events (10k) that can be sent per minute.", false)
        // todo immediate:  check with the team on better description.
        // todo later:  have griffon server return error description and how to solve... Same for connection & event limit errors
        case .deletedSession:
            return ("Session Deleted",
                    "You attempted to connect to a deleted session.", false)
        case .clientError:
            return ("Client Disconnected",
                    "This client has been disconnected due to an unexpected error. Error Code 4400.", false)
        case .userCancelled:
            return ("Assurance session connection cancelled.",
                    "User has chosen to cancel the socket connection. To start again, please open the app with an assurance deeplink url.", false)
        case .invalidURL(let url):
            return ("Invalid url",
                "Attempted a network request with an invalid url: \(url)", false)
        case .invalidResponseData:
            return ("Invalid response data",
                    "Received invalid response data", false)
        case .invalidRequestBody:
            return ("Invalid request body",
                    "Attempted a network request with an invalid request body", false)
        case .failedToRegisterDevice(let statusCode, let responseMessage):
            return ("Failed to register device",
                    "Failed to register device with status code: \(statusCode), and response message: \"\(responseMessage)\"", true)
        case .failedToGetDeviceStatus(let statusCode, let responseMessage):
            return ("Failed to get device status",
                    "Failed to get device status with status code: \(statusCode), and response message: \"\(responseMessage)\"", true)
        case .failedToDeleteDevice(let statusCode, let responseMessage):
            return ("Failed to delete device",
                    "Failed to delete device with status code: \(statusCode), and response message: \"\(responseMessage)\"", true)
        }
    }
}
