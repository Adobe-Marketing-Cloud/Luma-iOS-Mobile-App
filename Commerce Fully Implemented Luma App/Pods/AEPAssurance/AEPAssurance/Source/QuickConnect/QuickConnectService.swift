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
import UIKit

#if DEBUG
///
/// QuickConnectService is used to handle the Device APIs to connect with Assurance
///
class QuickConnectService {
    private let LOG_TAG = "QuickConnectService"
    var shouldRetryGetDeviceStatus = true
    typealias HTTP_RESPONSE_CODES = HttpConnectionConstants.ResponseCodes

    private let HEADERS = [HttpConnectionConstants.Header.HTTP_HEADER_KEY_ACCEPT: HttpConnectionConstants.Header.HTTP_HEADER_CONTENT_TYPE_JSON_APPLICATION,
                            HttpConnectionConstants.Header.HTTP_HEADER_KEY_CONTENT_TYPE: HttpConnectionConstants.Header.HTTP_HEADER_CONTENT_TYPE_JSON_APPLICATION]

    ///
    /// Registers this device to a specific org, the device will then appear in the Assurance UI
    /// - Parameters:
    ///     - clientID: `String` the clientID.
    ///     - orgID: `String` the orgID
    ///     - completion: `(AssuranceNetworkError?) -> Void` the completion which is nil if successful or an `AssuranceNetworkError` if there is a failure
    func registerDevice(clientID: String,
                        orgID: String,
                        completion: @escaping (AssuranceConnectionError?) -> Void) {
        
        /// Bail out with failure, if we are unable to form a valid create device API request URL
        let urlString = AssuranceConstants.QUICK_CONNECT_BASE_URL + "/create"
        guard let requestURL = URL(string: urlString) else {
            let error = AssuranceConnectionError.invalidURL(url: urlString)
            Log.error(label: LOG_TAG, error.info.description)
            completion(error)
            return
        }

        let parameters = [AssuranceConstants.QuickConnect.KEY_ORGID: orgID,
                          AssuranceConstants.QuickConnect.KEY_DEVICE_NAME: UIDevice.current.name,
                          AssuranceConstants.QuickConnect.KEY_CLIENT_ID: clientID]

        /// Bail out with failure, if we are unable to create the request body required for the API
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            let error = AssuranceConnectionError.invalidRequestBody
            Log.error(label: LOG_TAG, error.info.description)
            completion(error)
            return
        }

        /// Create the request
        let request = NetworkRequest(url: requestURL,
                                     httpMethod: HttpMethod.post,
                                     connectPayloadData: body,
                                     httpHeaders: HEADERS,
                                     connectTimeout: AssuranceConstants.Network.CONNECTION_TIMEOUT,
                                     readTimeout: AssuranceConstants.Network.READ_TIMEOUT)

        ServiceProvider.shared.networkService.connectAsync(networkRequest: request) { connection in

            if !(connection.responseCode == HTTP_RESPONSE_CODES.HTTP_OK || connection.responseCode == 201) {
                let error = AssuranceConnectionError.failedToRegisterDevice(statusCode: connection.responseCode ?? -1, responseMessage: connection.responseMessage ?? "Unkown error")
                Log.error(label: self.LOG_TAG, error.info.description)
                completion(error)
                return
            }
            guard let data = connection.data, let responseJson = try? JSONDecoder().decode([String: AnyCodable].self, from: data) else {
                Log.error(label: self.LOG_TAG, AssuranceConnectionError.invalidResponseData.info.description)
                completion(.invalidResponseData)
                return
            }
            Log.debug(label: self.LOG_TAG, "Created device \(String(describing: responseJson))")

            completion(nil)
            return
        }
    }

    ///
    /// Gets the device status from Assurance services
    /// - Parameters:
    ///     - clientID: `String` the clientID.
    ///     - orgID: `String` the ogID
    ///     - completion: `(Result<(session:ID: `String`, token: `String`), AssuranceNetworkError>) -> Void` the completion which is a `Result` with sessionID and token if successful or an `AssuranceNetworkError` if there is a failure
    ///
    func getDeviceStatus(clientID: String,
                         orgID: String,
                         completion: @escaping (Result<(sessionID: String, token: Int), AssuranceConnectionError>) -> Void) {

        /// Bail out with failure, if we are unable to form a valid create device API request URL
        let urlString = AssuranceConstants.QUICK_CONNECT_BASE_URL + "/status"
        guard let requestURL = URL(string: urlString) else {
            let error = AssuranceConnectionError.invalidURL(url: urlString)
            Log.error(label: self.LOG_TAG, error.info.description)
            completion(.failure(error))
            return
        }

        let parameters = [AssuranceConstants.QuickConnect.KEY_ORGID: orgID, AssuranceConstants.QuickConnect.KEY_CLIENT_ID: clientID]

        /// Bail out with failure, if we are unable to create the request body required for the API
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            let error = AssuranceConnectionError.invalidRequestBody
            Log.error(label: self.LOG_TAG, error.info.description)
            completion(.failure(error))
            return
        }

        /// Create the request
        let request = NetworkRequest(url: requestURL,
                                     httpMethod: HttpMethod.post,
                                     connectPayloadData: body,
                                     httpHeaders: HEADERS,
                                     connectTimeout: AssuranceConstants.Network.CONNECTION_TIMEOUT,
                                     readTimeout: AssuranceConstants.Network.READ_TIMEOUT)

        ServiceProvider.shared.networkService.connectAsync(networkRequest: request) { connection in
            if !(connection.responseCode == HTTP_RESPONSE_CODES.HTTP_OK || connection.responseCode == 201) {
                let error = AssuranceConnectionError.failedToGetDeviceStatus(statusCode: connection.responseCode ?? -1, responseMessage: connection.responseMessage ?? "Unknown error")
                Log.error(label: self.LOG_TAG, error.info.description)
                completion(.failure(error))
                return
            }

            if let data = connection.data, let responseDict = try? JSONDecoder().decode([String: AnyCodable].self, from: data) {
                let sessionID = responseDict["sessionUuid"]?.stringValue
                let token = responseDict["token"]?.intValue

                Log.debug(label: self.LOG_TAG, "Device status \(String(describing: responseDict))")
                guard let sessionID = sessionID, let token = token else {
                    if self.shouldRetryGetDeviceStatus {
                        sleep(2)
                        self.getDeviceStatus(clientID: clientID, orgID: orgID, completion: completion)
                    }
                    return
                }
                self.shouldRetryGetDeviceStatus = false
                completion(.success((sessionID: sessionID, token: token)))

                return
            }
            let error = AssuranceConnectionError.invalidResponseData
            Log.error(label: self.LOG_TAG, error.info.description)
            completion(.failure(error))
            return
        }
    }

    ///
    /// Deletes this device from the org
    /// - Parameters:
    ///     - clientID: `String` the clientID.
    ///     - orgID: `String` the orgID
    ///     - completion: `(AssuranceNetworkError?) -> Void` the completion which is nil if successful or an `AssuranceNetworkError` if there is a failure
    func deleteDevice(clientID: String,
                      orgID: String,
                      completion: @escaping (AssuranceConnectionError?) -> Void) {

        /// Bail out with failure, if we are unable to form a valid create device API request URL
        let urlString = AssuranceConstants.QUICK_CONNECT_BASE_URL + "/delete"
        guard let requestURL = URL(string: urlString) else {
            let error = AssuranceConnectionError.invalidURL(url: urlString)
            Log.error(label: self.LOG_TAG, error.info.description)
            completion(error)
            return
        }

        let parameters = [AssuranceConstants.QuickConnect.KEY_ORGID: orgID,
                          AssuranceConstants.QuickConnect.KEY_DEVICE_NAME: UIDevice.current.name,
                          AssuranceConstants.QuickConnect.KEY_CLIENT_ID: clientID]

        /// Bail out with failure, if we are unable to create the request body required for the API
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            let error = AssuranceConnectionError.invalidRequestBody
            Log.error(label: self.LOG_TAG, error.info.description)
            completion(error)
            return
        }

        /// Create the request
        let request = NetworkRequest(url: requestURL,
                                     httpMethod: HttpMethod.post,
                                     connectPayloadData: body,
                                     httpHeaders: HEADERS,
                                     connectTimeout: AssuranceConstants.Network.CONNECTION_TIMEOUT,
                                     readTimeout: AssuranceConstants.Network.READ_TIMEOUT)

        ServiceProvider.shared.networkService.connectAsync(networkRequest: request) { connection in

            if !(connection.responseCode == HTTP_RESPONSE_CODES.HTTP_OK || connection.responseCode == 201) {
                let error = AssuranceConnectionError.failedToDeleteDevice(statusCode: connection.responseCode ?? -1, responseMessage: connection.responseMessage ?? "Unknown error")
                Log.error(label: self.LOG_TAG, error.info.description)
                completion(error)
                return
            }
            guard let data = connection.data, let responseJson = try? JSONDecoder().decode([String: AnyCodable].self, from: data) else {
                Log.error(label: self.LOG_TAG, AssuranceConnectionError.invalidResponseData.info.description)
                completion(.invalidResponseData)
                return
            }
            Log.debug(label: self.LOG_TAG, "Deleted device \(String(describing: responseJson))")
            completion(nil)
            return
        }
    }
}
#endif
