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

/// Plugin to dispatch fake events to Mobile Core.
///
/// The plugin gets invoked with Assurance command event having
///   - vendor :  "com.adobe.griffon.mobile"
///   - command type  :  "fakeEvent"
///
/// This plugin gets registered with `PluginHub` during the registration of Assurance extension.
/// Once a command to dispatch a fakeEvent is received.
/// This plugin extracts the SDK event details from the command, creates an `Event` and dispatches to `MobileCore`.
///
/// @see AssuranceConstants.PluginFakeEvent
struct PluginFakeEvent: AssurancePlugin {

    var vendor: String = AssuranceConstants.Vendor.MOBILE

    var commandType: String = AssuranceConstants.CommandType.FAKE_EVENT

    func receiveEvent(_ event: AssuranceEvent) {

        // extract the details of the fake event from the Assurance event's payload
        // 1. Read the event name
        guard let eventName = event.commandFakeEventName else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "PluginFakeEvent - Event name is null or not a valid string. Assurance SDK is ignoring the fake event command.")
            return
        }

        // 2. Read event source
        guard let eventSource = event.commandFakeEventSource else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "PluginFakeEvent -  Event source is null or not a string in the payload. Assurance SDK is ignoring the fake event command.")
            return
        }

        // 3. Read event type
        guard let eventType = event.commandFakeEventType else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "PluginFakeEvent - Event type is null or not a string in the payload. Assurance SDK is ignoring the fake event command.")
            return
        }

        // make and dispatch a fake event to eventHub
        let fakeEvent = Event(name: eventName, type: eventType, source: eventSource, data: event.commandFakeEventData)
        MobileCore.dispatch(event: fakeEvent)
    }

    // no op - protocol methods
    func onRegistered(_ session: AssuranceSession) {}

    func onSessionConnected() {}

    func onSessionDisconnectedWithCloseCode(_ closeCode: Int) {}

    func onSessionTerminated() {}

}

/// AssuranceEvent extension to simplify reading of command detail keys for PluginFakeEvent
private extension AssuranceEvent {

    var commandFakeEventName: String? {
        return commandDetails?[AssuranceConstants.PluginFakeEvent.NAME] as? String
    }

    var commandFakeEventType: String? {
        return commandDetails?[AssuranceConstants.PluginFakeEvent.TYPE] as? String
    }

    var commandFakeEventSource: String? {
        return commandDetails?[AssuranceConstants.PluginFakeEvent.SOURCE] as? String
    }

    var commandFakeEventData: [String: Any]? {
        return commandDetails?[AssuranceConstants.PluginFakeEvent.DATA] as? [String: Any]
    }
}
