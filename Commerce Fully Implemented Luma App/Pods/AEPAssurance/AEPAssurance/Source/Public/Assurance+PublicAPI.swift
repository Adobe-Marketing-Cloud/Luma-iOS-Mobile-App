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

@objc public extension Assurance {

    /// Starts an AEPAssurance session.
    ///
    /// Calling this method when a session has already been started results in a no-op, otherwise it attempts to initiate a new AEPAssurance session.
    /// A call to this API with an non griffon session url will be ignored
    ///
    /// - Parameter url: a valid AEPAssurance URL to start a session
    ///
    static func startSession(url: URL?) {
        guard let urlString = url?.absoluteString else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Start Session API called with invalid Assurance deeplink, ignoring the API call.")
            return
        }

        if !urlString.contains(AssuranceConstants.Deeplink.SESSIONID_KEY) {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Start Session API called with missing assurance sessionID, ignoring the API call. URL : \(urlString)")
            return
        }

        Log.trace(label: AssuranceConstants.LOG_TAG, "Start Session API called with deeplink URL : \(urlString)")
        let eventData = [AssuranceConstants.EventDataKey.START_SESSION_URL: urlString]
        let event = Event(name: "Assurance Start Session",
                          type: AssuranceConstants.SDKEventType.ASSURANCE,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event)
    }

}
