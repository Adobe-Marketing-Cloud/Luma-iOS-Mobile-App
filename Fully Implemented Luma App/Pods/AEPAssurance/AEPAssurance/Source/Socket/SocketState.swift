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

/// Constants that indicate the states of the socket connection
enum SocketState {
    /// The socket connection is initiated and it is in progress.
    case connecting

    /// Socket connection state is established and currently receiving and forwarding events.
    case open

    /// Socket connection disconnect has been initiated but has not completely disconnected yet.
    case closing

    /// Socket connection is completely terminated and is no more receiving or forwarding events.
    case closed

    /// Current state of the socket is unknown
    case unknown
}
