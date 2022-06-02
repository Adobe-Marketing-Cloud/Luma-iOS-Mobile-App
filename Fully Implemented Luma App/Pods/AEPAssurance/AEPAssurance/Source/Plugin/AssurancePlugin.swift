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

/// The protocol that needs to be adopted by a class to receive and respond to Assurance commands
///
/// You can define an AssurancePlugin with a vendor name and command type. These plugins can then be used to handle the commands from the Griffon UI directed towards them.
///  An Inbound command with a specified vendor and command type will invoke the  plugin.
///  WildCardPlugin : `AssurancePlugin` with commandType "wildcard" will listen all the command for its defined vendor.
protocol AssurancePlugin {

    /// the vendor name for the Assurance plugin
    var vendor: String { get }

    /// the command type for the Assurance plugin
    var commandType: String { get }

    /// This protocol method is invoked when plugin is successfully registered to the AssuranceSession.
    /// - Parameter session : an instance of the active Assurance Session
    func onRegistered(_ session: AssuranceSession)

    /// This protocol method is invoked when an AEPAssuranceEvent is received for a specific vendor.
    /// - Parameter event : an AssuranceEvent designated for the listening vendor
    func receiveEvent(_ event: AssuranceEvent)

    /// This protocol method is invoked when a successful Assurance socket connection is established.
    func onSessionConnected()

    ///  This protocol method is invoked when an Assurance session is disconnected.
    ///  More information about various close code could be found here : https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
    /// - Parameter closeCode : an integer value representing the reason for webSocket disconnect
    func onSessionDisconnectedWithCloseCode(_ closeCode: Int)

    /// This protocol method is invoked when Assurance session is disconnected and the Assurance Floating UI button is removed.
    /// Invocation of this method guarantees that the Assurance session is completely terminated and the Assurance extension will not automatically
    /// reconnect the session on the next app launch.
    func onSessionTerminated()
}
