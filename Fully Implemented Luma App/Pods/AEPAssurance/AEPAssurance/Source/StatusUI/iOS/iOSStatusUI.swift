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

class iOSStatusUI {
    var assuranceSession: AssuranceSession
    var clientLogQueue: ThreadSafeQueue<AssuranceClientLogMessage>
    var floatingButton: FloatingButtonPresentable?
    var fullScreenMessage: FullscreenPresentable?
    var webView: WKWebView?

    required init(withSession assuranceSession: AssuranceSession) {
        self.assuranceSession = assuranceSession
        self.clientLogQueue = ThreadSafeQueue(withLimit: 100)
    }

    /// Displays the Assurance Status UI on the customers application.
    /// This method will initialize the FloatingButton and the FullScreen webView required for the displaying Assurance status.
    /// On calling this method Floating button appears on the screen showing the current connection status.
    func display() {
        if let _ = floatingButton {
            return
        }

        if fullScreenMessage == nil {
            self.fullScreenMessage = ServiceProvider.shared.uiService.createFullscreenMessage(payload: String(bytes: StatusInfoHTML.content, encoding: .utf8) ?? "", listener: self, isLocalImageUsed: false)
        }

        floatingButton = ServiceProvider.shared.uiService.createFloatingButton(listener: self)
        floatingButton?.setInitial(position: FloatingButtonPosition.topRight)
        floatingButton?.show()
    }

    ///
    /// Removes Assurance Status UI from the customers application
    ///
    func remove() {
        self.floatingButton?.dismiss()
        self.floatingButton = nil
        self.fullScreenMessage = nil
        self.webView = nil
    }

    ///
    /// Updates Assurance Status UI to denote socket is currently connected.
    ///
    func updateForSocketConnected() {
        addClientLog("Assurance connection established.", visibility: .low)
        floatingButton?.setButtonImage(imageData: Data(bytes: ActiveIcon.content, count: ActiveIcon.content.count))
    }

    ///
    /// Updates Assurance Status UI to denote socket connection is currently inactive.
    ///
    func updateForSocketInActive() {
        addClientLog("Attempting to reconnect..", visibility: .low)
        floatingButton?.setButtonImage(imageData: Data(bytes: InactiveIcon.content, count: InactiveIcon.content.count))
    }

    ///
    /// Appends the logs to Assurance Status UI
    /// - Parameters:
    ///     - message: `String` log message.
    ///     - visibility: an `AssuranceClientLogVisibility` determining the importance of the log message.
    ///
    func addClientLog(_ message: String, visibility: AssuranceClientLogVisibility) {
        clientLogQueue.enqueue(newElement: AssuranceClientLogMessage(withVisibility: visibility, andMessage: message))
        updateLogUI()
    }

    ///
    /// Load and display all the pending log messages on Assurance Status UI.
    ///
    func updateLogUI() {
        guard let webView = webView else {
            return
        }

        while clientLogQueue.size() > 0 {
            guard let logMessage = clientLogQueue.dequeue() else {
                return
            }

            var cleanMessage = logMessage.message.replacingOccurrences(of: "\\", with: "\\\\")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\"", with: "\\\"")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\n", with: "<br>")
            cleanMessage = cleanMessage.replacingOccurrences(of: "\t", with: "&nbsp;&nbsp;&nbsp;&nbsp;")
            DispatchQueue.main.async {
                let logCommand = String(format: "addLog(\"%d\", \"%@\");", logMessage.visibility.rawValue, logMessage.message)
                webView.evaluateJavaScript(logCommand, completionHandler: { _, error in
                    if let error = error {
                        print("An error occurred while displaying client logs. Error Description: \(error.localizedDescription)")
                    }

                })
            }
        }
    }

}
