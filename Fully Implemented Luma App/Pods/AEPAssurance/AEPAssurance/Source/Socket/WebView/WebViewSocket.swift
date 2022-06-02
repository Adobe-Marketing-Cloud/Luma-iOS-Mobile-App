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

class WebViewSocket: NSObject, SocketConnectable, WKNavigationDelegate, WKScriptMessageHandler {

    var delegate: SocketDelegate
    var socketURL: URL?
    let eventChunker = AssuranceEventChunker()

    /// variable tracking the current socket status
    var socketState: SocketState = .unknown {
        didSet {
            delegate.webSocket(self, didChangeState: self.socketState)
        }
    }

    /// boolean that tracks if webView for making socket connection is loaded
    var isWebViewLoaded: Bool = false {
        didSet {
            if let socketURL = self.socketURL, isWebViewLoaded {
                connect(withUrl: socketURL)
            }
        }
    }

    // MARK: - Private properties

    private var webView: WKWebView?
    private var loadNav: WKNavigation?
    private var socketEventHandlers = ThreadSafeDictionary<String, messageHandlerBlock>(identifier: "com.adobe.assurance.socketEventHandler")
    private let socketQueue = DispatchQueue(label: "com.adobe.assurance.WebViewSocketConnection") // serial queue
    private let pageContent = "<HTML><HEAD></HEAD><BODY></BODY></HTML>"
    typealias messageHandlerBlock = (WKScriptMessage) -> Void

    // MARK: - SocketConnectable Interfaces

    /// Initialization of webView socket connection.
    /// - Parameters:
    ///     - delegate: the delegate instance to get notified on essential socket events
    required init(withDelegate delegate: SocketDelegate) {
        self.delegate = delegate
        super.init()

        // read the webSocket javascript from the built resources
        guard let socketJavascript = String(bytes: SocketScript.content, encoding: .utf8) else {
            Log.warning(label: AssuranceConstants.LOG_TAG, "Unable to load javascript string for webView socket connection.")
            return
        }

        // grab the main queue to set up webView for socket connection
        // WebView Initialization should be run on main thread
        DispatchQueue.main.async {
            self.webView = WKWebView(frame: CGRect.zero)
            self.webView?.configuration.userContentController.addUserScript(WKUserScript(source: socketJavascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
            self.setupCallbacks()
            self.webView?.navigationDelegate = self
            self.loadNav = self.webView?.loadHTMLString(self.pageContent, baseURL: nil)
        }
    }

    /// Makes a socket connection with the provided URL
    /// Sets the socket state to `CONNECTING` and attempts to make a connection.
    /// On successful connection the SocketDelegate's `webSocketDidConnect` method is invoked.
    /// On any error,  the SocketDelegate's `webSocketOnError` method is invoked.
    /// - Parameters :
    ///     - url : the webSocket `URL`
    func connect(withUrl url: URL) {
        self.socketState = .connecting
        self.socketURL = url
        if !isWebViewLoaded {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Waiting for webView to be loaded open socket connection.")
            return
        }

        socketQueue.async {
            let connectCommand = String(format: "connect(\"%@\");", url.absoluteString)
            self.runJavascriptCommand(connectCommand, { error in
                if error != nil {
                    Log.debug(label: AssuranceConstants.LOG_TAG, "An error occurred while opening connection - \(String(describing: error?.localizedDescription))")
                }
            })
        }
    }

    /// Disconnect the ongoing socket connection.
    /// Sets the socket state to `CLOSING` and attempts for disconnection
    /// On successful disconnection  the SocketDelegate's `webSocketDidDisconnect` method is invoked.
    /// And the socket state is set to `CLOSED`.
    /// On any error,  the SocketDelegate's `webSocketOnError` method is invoked.
    func disconnect() {
        self.socketState = .closing
        socketQueue.async {
            self.runJavascriptCommand("disconnect();", { error in
                if error != nil {
                    Log.debug(label: AssuranceConstants.LOG_TAG, "An error occurred while closing connection - \(String(describing: error?.localizedDescription))")
                }
            })
        }
    }

    /// Sends the `AssuranceEvent` over the socket connection.
    /// Make sure you have the socket connection established before calling this API.
    /// On any error,  the SocketDelegate's `webSocketOnError` method is invoked.
    /// - Parameters :
    ///     - event : the event to be sent to Assurance session
    func sendEvent(_ event: AssuranceEvent) {
        socketQueue.async { [self] in
            /// Pass the event through the chunker to chunk large events if necessary
            let chunkedEvents = self.eventChunker.chunk(event)
            for eachEvent in chunkedEvents {
                let jsonData = eachEvent.jsonData
                self.sendDataOverSocket(jsonData)
            }
        }
    }

    // MARK: - WebView Delegate methods

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let block = self.socketEventHandlers[message.name]
        block?(message)
    }

    // Called after page is loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation == self.loadNav {
            Log.trace(label: AssuranceConstants.LOG_TAG, "WKWebView initialization complete with socket connection javascript.")
            isWebViewLoaded = true
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if navigation == self.loadNav {
            Log.debug(label: AssuranceConstants.LOG_TAG, "WKWebView failed to load bundled JS for socket. Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Private methods

    private func setupCallbacks() {
        registerSocketCallback("log", with: { message in
            Log.debug(label: AssuranceConstants.LOG_TAG, "Javascript log output : \(message.body)")
        })

        registerSocketCallback("onopen", with: { _ in
            self.socketState = .open
            self.delegate.webSocketDidConnect(self)
        })

        registerSocketCallback("onerror", with: { _ in
            self.delegate.webSocketOnError(self)
        })

        registerSocketCallback("onclose", with: { message in
            self.socketState = .closed
            self.socketURL = nil
            // message body obtained from on close call has the following keys
            // 1. closeCode   - an Integer representing closeCode for the socket
            // 2. reason      - a string value representing the reason for socket closure
            // 3. wasClean    - a boolean that Indicates whether or not the connection was cleanly closed.
            guard let messageBody = message.body as? [String: Any] else {
                return
            }

            let closeCode = messageBody["closeCode"] as? Int ?? -1
            let reason = messageBody["reason"] as? String ?? ""
            let wasClean = messageBody["wasClean"] as? Bool ?? false
            self.delegate.webSocketDidDisconnect(self, closeCode, reason, wasClean)
        })

        registerSocketCallback("onmessage", with: { message in

            guard let messageBody = message.body as? String else {
                Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to read the socket message as string. Ignoring the incoming event.")
                return
            }
            guard let data = messageBody.data(using: .utf8) else {
                Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to convert the received socket message to data. Ignoring the incoming event.")
                return
            }
            guard let receivedEvent = AssuranceEvent.from(jsonData: data) else {
                return
            }

            self.delegate.webSocket(self, didReceiveEvent: receivedEvent)
        })

    }

    /// Call this method to send the data through the  established socket connection
    /// Before calling this method, make sure the data size is within the limit of an assurance socket (32MB).
    /// Failing to do so will result in socket disconnection with error code 1009
    /// - Parameters :
    ///     - jsonData : the encoded data to be sent over socket
    private func sendDataOverSocket(_ jsonData: Data) {
        let dataString = jsonData.base64EncodedString(options: .endLineWithLineFeed)
        let jsCommand = String(format: "sendData(\"%@\");", dataString)
        self.runJavascriptCommand(jsCommand, { error in
            if error != nil {
                Log.debug(label: AssuranceConstants.LOG_TAG, "An error occurred while sending data - \(String(describing: error?.localizedDescription))")
            }
        })
    }

    /// Helper method configure socket event handlers.
    private func registerSocketCallback(_ name: String, with block : @escaping messageHandlerBlock) {
        self.webView?.configuration.userContentController.add(self, name: name)
        self.socketEventHandlers[name] = block
    }

    /// Helper method to run javascript commands on webView.
    private func runJavascriptCommand(_ jsCommand: String, _ callbackError : @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(jsCommand, completionHandler: { _, error in
                callbackError(error)
            })
        }
    }

}
