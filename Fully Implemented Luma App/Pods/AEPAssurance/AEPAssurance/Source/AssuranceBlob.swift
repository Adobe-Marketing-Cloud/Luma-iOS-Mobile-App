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

enum AssuranceBlob {

    static let HTTPS_SCHEME = "https"
    static let HOST_FORMAT = "blob%@.griffon.adobe.com"
    static let UPLOAD_PATH = "/api/FileUpload"
    static let QUERY_VALIDATION_SESSION_ID = "validationSessionId"

    static let HTTP_HEADER_KEY_FILE_CONTENT_TYPE = "File-Content-Type"
    static let HTTP_HEADER_VALUE_OCTET_STREAM = "application/octet-stream"

    static let HTTP_STATUS_CODE_OK = 200
    static let HTTP_STATUS_CODE_ACCEPTED = 202

    static let CONNECTION_TIMEOUT = 30.0

    typealias HttpConstants = HttpConnectionConstants.Header

    /// Sends a binary blob data to Assurance server to be recorded as an 'asset' for the current session.
    /// Posts the binary blob to Assurance with the given contentType. Expects server to respond with a JSON object
    /// containing at one of the following keys (both will have string values):
    ///    'asset' - contains asset ID of the newly stored asset
    ///    'error' - description of an error that occurred
    ///
    /// The callback `BlobResult` is called with valid blobID string if the upload of the binary data was successful.
    /// In any other error scenarios the callback is called with nil blobID.
    ///
    /// - Parameters:
    ///     - blob: The binary data to transmit.
    ///     - session: The connected `AssuranceSession` to which the data belongs
    ///     - contentType:String containing the MIME type of the blob.
    ///     - blobResult : A callback to be executed once upload has completed (either successfully or with an error)
    static func sendBlob(_ blob: Data, forSession session: AssuranceSession, contentType: String, callback : @escaping (String?) -> Void) {

        var components = URLComponents()
        components.scheme = HTTPS_SCHEME
        components.host = String.init(format: HOST_FORMAT, session.assuranceExtension.environment.urlFormat)
        components.path = UPLOAD_PATH
        components.queryItems = [
            URLQueryItem(name: QUERY_VALIDATION_SESSION_ID, value: session.assuranceExtension.sessionId)
        ]

        let headers = [HttpConstants.HTTP_HEADER_KEY_ACCEPT: HttpConstants.HTTP_HEADER_CONTENT_TYPE_JSON_APPLICATION,
                       HttpConstants.HTTP_HEADER_KEY_CONTENT_TYPE: HTTP_HEADER_VALUE_OCTET_STREAM,
                       HTTP_HEADER_KEY_FILE_CONTENT_TYPE: contentType]
        guard let url = components.url else {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Invalid blob url. Unable to send blob data.")
            return
        }
        let networkRequest = NetworkRequest(url: url,
                                            httpMethod: HttpMethod.post,
                                            connectPayloadData: blob,
                                            httpHeaders: headers,
                                            connectTimeout: CONNECTION_TIMEOUT,
                                            readTimeout: CONNECTION_TIMEOUT)

        Log.debug(label: AssuranceConstants.LOG_TAG, "Uploading blob data to URL : \(url.absoluteString)")
        ServiceProvider.shared.networkService.connectAsync(networkRequest: networkRequest, completionHandler: { connection in
            handleNetworkResponse(connection: connection, callback: callback)
        })
    }

    // MARK: Helpers

    /// Handles the network response of a blob upload request
    /// The callback blobResult is invoked with the `blobID` if the upload was successful. Nil otherwise.
    /// - Parameters:
    ///   - connection: the connection returned after we make the network request
    ///   - callback: a completion block to be invoked with the blobID
    private static func handleNetworkResponse(connection: HttpConnection, callback: @escaping (String?) -> Void) {
        // bail out if we get any responseCode other than 200 or 202
        if !(connection.responseCode == HTTP_STATUS_CODE_OK || connection.responseCode == HTTP_STATUS_CODE_ACCEPTED) {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Blob upload failed. Connection status code : \(connection.responseCode ?? -1) and error \(connection.responseMessage ?? "Unknown error")")
            callback(nil)
            return
        }

        if let data = connection.data, let blobDict = try? JSONDecoder().decode([String: AnyCodable].self, from: data) {
            guard let blobID = blobDict["id"]?.stringValue else {
                Log.warning(label: AssuranceConstants.LOG_TAG, "Blob upload failed with error : \(blobDict["error"] ?? "Unknown Error")")
                callback(nil)
                return
            }
            // on successful retrieval, invoke the callback with blobID
            callback(blobID)

        } else {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Failed to upload blob with status code \(connection.responseCode ?? -1) and error : \(connection.error?.localizedDescription ?? "Unknown error")")
            callback(nil)
        }
    }
}
