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

class ErrorView: FullscreenMessageDelegate {

    var error: AssuranceConnectionError
    var fullscreenMessage: FullscreenPresentable?
    var fullscreenWebView: WKWebView?

    /// Initializer
    init(_ error: AssuranceConnectionError) {
        self.error = error
    }

    func display() {
        fullscreenMessage = ServiceProvider.shared.uiService.createFullscreenMessage(payload: String(bytes: PinDialogHTML.content, encoding: .utf8) ?? "", listener: self, isLocalImageUsed: false)
        fullscreenMessage?.show()
    }

    func onShow(message: FullscreenMessage) {
        fullscreenWebView = message.webView as? WKWebView
    }

    func onDismiss(message: FullscreenMessage) {
        fullscreenWebView = nil
        fullscreenMessage = nil
    }

    func overrideUrlLoad(message: FullscreenMessage, url: String?) -> Bool {
        // no operation if we are unable to find the host of the url
        // return true, so force core to handle the URL
        guard let host = URL(string: url ?? "")?.host else {
            return true
        }

        // when the user hits "Cancel" on the iOS pinpad screen. Dismiss the fullscreen message
        // return false, to indicate that the URL has been handled
        if host == AssuranceConstants.HTMLURLPath.CANCEL {
            message.dismiss()
            return false
        }

        return true
    }

    func webViewDidFinishInitialLoading(webView: WKWebView) {
        showErrorDialogToUser()
    }

    func onShowFailure() {
        Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to display Assurance error screen. Assurance session terminated.")
    }

    private func showErrorDialogToUser() {
        Log.debug(label: AssuranceConstants.LOG_TAG, String(format: "Assurance connection establishment failed. Error : %@, Description : %@", error.info.name, error.info.description))
        let jsFunctionCall = String(format: "showError('%@','%@', %d);", error.info.name, error.info.description, false)
        fullscreenWebView?.evaluateJavaScript(jsFunctionCall, completionHandler: nil)
    }

}
