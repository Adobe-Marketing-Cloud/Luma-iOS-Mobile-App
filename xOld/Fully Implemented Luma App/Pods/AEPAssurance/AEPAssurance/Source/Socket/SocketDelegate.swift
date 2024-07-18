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

/// Methods for adopted by the object to manage the events from the web-socket connection
protocol SocketDelegate {

    /// Tells the delegate when the socket connection has been successfully made
    /// - Parameters:
    ///     - socket:the instance of `SocketConnectable` that is connected.
    func webSocketDidConnect(_ socket: SocketConnectable)

    /// Tells the delegate when the socket is disconnected
    /// - Parameters:
    ///     - socket: the instance of `SocketConnectable` that is disconnected
    ///     - closeCode:An `Int` representing the reason for socket disconnection. Reference : https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
    ///     - reason: A `String` description for the reason of disconnection
    ///     - wasClean: A boolean representing if the connection has been terminated successfully. A false value represents the socket connection can be attempted to reconnected.
    func webSocketDidDisconnect(_ socket: SocketConnectable, _ closeCode: Int, _ reason: String, _ wasClean: Bool)

    /// Tells the delegate when there is any error in socket connection
    /// - Parameters:
    ///     - socket: the instance of `SocketConnectable`
    func webSocketOnError(_ socket: SocketConnectable)

    /// Handles a socket event received from the web-socket
    /// - Parameters:
    ///     - socket:the instance of `SocketConnectable`
    ///     - event:the message received from the socket connection converted as  `AssuranceEvent`
    func webSocket(_ socket: SocketConnectable, didReceiveEvent event: AssuranceEvent)

    /// Informs the observer object about the change in the socket connection status.
    /// - Parameters:
    ///     - socket:the instance of `SocketConnectable`
    ///     - state: `SocketState`representing the current status of the socket connection
    func webSocket(_ socket: SocketConnectable, didChangeState state: SocketState)
}
