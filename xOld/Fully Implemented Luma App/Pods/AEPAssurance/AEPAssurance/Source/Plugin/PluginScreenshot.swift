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
import UIKit

/// Plugin that acts on command to capture the screenshot of the iOS device
///
/// The plugin gets invoked with Assurance command event having
/// - vendor  : "com.adobe.griffon.mobile"
/// - command type   : "screenshot"
///
/// This plugin gets registered with `PluginHub` during the registration of Assurance extension.
/// Once the command to capture a screenshot is received, this plugin uses the `AssuranceBlob` service to upload the screenshot data.
/// The ` AssuranceBlob` service then responds with the blobID of the uploaded screenshot image. This blobID is then forwarded to the ongoing assurance session.
/// Failure to upload the screenshot will result in not sending any event to assurance session.
class PluginScreenshot: AssurancePlugin {

    weak var session: AssuranceSession?
    var uiUtil = AssuranceUIUtil()
    var vendor: String = AssuranceConstants.Vendor.MOBILE
    var commandType: String = AssuranceConstants.CommandType.SCREENSHOT

    /// this protocol method is called from `PluginHub` to handle screenshot command
    func receiveEvent(_ event: AssuranceEvent) {
        // quick bail, if you cannot read the session instance
        guard let session = self.session else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to get the session instance. Ignoring the screenShot request.")
            return
        }

        uiUtil.takeScreenshot({ imageData in

            guard let imageData = imageData else {
                Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to capture screenshot from the device. Ignoring the screenShot request.")
                return
            }

            AssuranceBlob.sendBlob(imageData, forSession: session, contentType: "image/png", callback: { blobID in
                if blobID != nil {
                    let assuranceEvent = AssuranceEvent(type: AssuranceConstants.EventType.BLOB, payload: ["blobId": AnyCodable(blobID), "mimeType": "image/png"])
                    self.session?.sendEvent(assuranceEvent)
                } else {
                    Log.debug(label: AssuranceConstants.LOG_TAG, "Uploading screenshot failed. Ignoring the screenShot request.")
                }
            })
        })
    }

    /// protocol method is called from this Plugin is registered with `PluginHub`
    func onRegistered(_ session: AssuranceSession) {
        self.session = session
    }

    // no op - protocol methods
    func onSessionConnected() {}

    func onSessionDisconnectedWithCloseCode(_ closeCode: Int) {}

    func onSessionTerminated() {}

}
