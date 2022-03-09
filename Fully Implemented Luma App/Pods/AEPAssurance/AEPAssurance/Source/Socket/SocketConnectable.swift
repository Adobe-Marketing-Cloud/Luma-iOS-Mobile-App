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

/// protocol that needs to be followed by the class that implements the socket connection
protocol SocketConnectable {
    /// the web socket URL
    var socketURL: URL? {get}

    /// the delegate that gets notified on socket events.
    var delegate: SocketDelegate { get }

    /// Initializes a socketConnectable with a listener
    /// - Parameters:
    /// - listener : A `SocketEventListener` to manage the socket events
    init(withDelegate delegate: SocketDelegate)

    /// A property that holds the current state of socket connection.
    var socketState: SocketState { get }

    /// Call this methods to initiate the socket connect with the provided URL.
    func connect(withUrl url: URL)

    /// Call this methods to disconnect the ongoing socket connection.
    func disconnect()

    /// Use this method to send an AssuranceEvent over the socket connection.
    func sendEvent(_ event: AssuranceEvent)
}
