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
import WebKit

extension iOSStatusUI: FullscreenMessageDelegate {

    /// Invoked when statusUI fullscreen message is displayed
    /// - Parameters:
    ///     - message: statusUI fullscreen message
    func onShow(message: FullscreenMessage) {
    }

    /// Invoked when statusUI fullscreen message is dismissed
    /// - Parameters:
    ///     - message: statusUI fullscreen message
    func onDismiss(message: FullscreenMessage) {
    }

    /// Invoked when the statusUI fullscreen message is attempting to load a url
    /// - Parameters:
    ///     - message: statusUI fullscreen message
    ///     - url:     String the url being loaded by the message
    /// - Returns: True if the core wants to handle the URL (and not the fullscreen message view implementation)
    func overrideUrlLoad(message: FullscreenMessage, url: String?) -> Bool {
        self.webView = message.webView as? WKWebView
        // no operation if we are unable to find the host of the url
        // return true, so force core to handle the URL
        guard let host = URL(string: url ?? "")?.host else {
            return true
        }

        // when the user hits "Cancel" on statusUI screen. Dismiss the fullscreen message
        // return false, to indicate that the URL has been handled
        if host == AssuranceConstants.HTMLURLPath.CANCEL {
            message.hide()
            floatingButton?.show()
            return false
        }

        // when the user hits "Disconnect" on statusUI screen. Dismiss the fullscreen message
        // Notify the AssuranceSession instance to disconnect. And remove the floating button
        // return false, to indicate that the URL has been handled
        if host == AssuranceConstants.HTMLURLPath.DISCONNECT {
            message.dismiss()
            assuranceSession.terminateSession()
            return false
        }

        return true
    }

    /// Invoked when the fullscreen message finished loading its first content on the webView.
    /// - Parameter webView - the `WKWebView` instance that completed loading its initial content.
    func webViewDidFinishInitialLoading(webView: WKWebView) {
        updateLogUI()
    }

    ///
    /// Invoked when failure to display the statusUI fullscreen message
    ///
    func onShowFailure() {
        Log.warning(label: AssuranceConstants.LOG_TAG, "Unable to display the statusUI screen, onShowFailure delegate method is invoked")
    }
}
