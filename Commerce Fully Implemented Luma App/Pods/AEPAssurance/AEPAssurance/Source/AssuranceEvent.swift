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

/// Event object used to transport data to/from Assurance server.
///
/// This object is intentionally opaque (internal). If this needs to be public,
/// refactor this class to reflect a builder pattern enforcing size limits on
/// constituents of the AssuranceEvent like metadata.
struct AssuranceEvent: Codable {
    var eventID: String = UUID().uuidString
    var vendor: String
    var type: String
    var payload: [String: AnyCodable]?
    var eventNumber: Int32?
    var timestamp: Date?
    var metadata: [String: AnyCodable]?

    /// Decodes a JSON data into a `AssuranceEvent`
    ///
    /// The following keys are required in the provided JSON:
    ///      - eventID - A unique UUID string to identify the event
    ///      - vendor - A vendor string
    ///      - type - A string describing the type of the event
    ///      - timestamp - A whole number representing milliseconds since the Unix epoch
    ///      - payload (optional) - A JSON object containing the event's payload
    ///
    /// This method will return nil if called under any of the following conditions:
    ///      - The provided json is not valid
    ///      - The provided json is not an object at its root
    ///      - Any of the required keys are missing (see above for a list of required keys)
    ///      - Any of the required keys do not contain the correct type of data
    ///
    /// - Parameters:
    ///   - jsonData: jsonData representing `AssuranceEvent`
    ///
    /// - Returns: a `AssuranceEvent` that is represented in the json data, nil if data is not in the correct format
    static func from(jsonData: Data) -> AssuranceEvent? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        guard var event = try? decoder.decode(AssuranceEvent.self, from: jsonData) else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "Unable to decode jsonData into an AssuranceEvent.")
            return nil
        }
        event.eventNumber = AssuranceEvent.generateEventNumber()
        if event.timestamp == nil {
            event.timestamp = Date()
        }
        return event
    }

    /// Creates an `AssuranceEvent` from `Event` obtained from MobileCore.
    /// Captures the id, name, type, source, eventData and timestamp into the payload of the AssuranceEvent
    /// All the `AssuranceEvent` derived from MobileCore events are tagged as `Generic` type.
    /// All the `AssuranceEvent` derived from MobileCore events are tagged with Vendor `Mobile`
    ///
    /// - Parameters:
    ///     - mobileCoreEvent:An event from MobileCore dispatched by event-hub and captured by wild card listener.
    /// - Returns: an `AssuranceEvent`
    static func from(event: Event) -> AssuranceEvent {
        var payload: [String: AnyCodable] = [:]
        payload[AssuranceConstants.ACPExtensionEventKey.NAME] = AnyCodable.init(event.name)
        payload[AssuranceConstants.ACPExtensionEventKey.TYPE] = AnyCodable.init(event.type.lowercased())
        payload[AssuranceConstants.ACPExtensionEventKey.SOURCE] = AnyCodable.init(event.source.lowercased())
        payload[AssuranceConstants.ACPExtensionEventKey.UNIQUE_IDENTIFIER] = AnyCodable.init(event.id.uuidString)
        payload[AssuranceConstants.ACPExtensionEventKey.TIMESTAMP] = AnyCodable.init(event.timestamp)

        // if available, add eventData
        if let eventData = event.data {
            payload[AssuranceConstants.ACPExtensionEventKey.DATA] = AnyCodable.init(eventData)
        }

        // if available, add responseID
        if  let responseID = event.responseID {
            payload[AssuranceConstants.ACPExtensionEventKey.RESPONSE_IDENTIFIER] = AnyCodable.init(responseID.uuidString)
        }

        return AssuranceEvent(type: AssuranceConstants.EventType.GENERIC, payload: payload)
    }

    /// Initializer to construct `AssuranceEvent`instance with the given parameters
    ///
    /// - Parameters:
    ///   - type: a String describing the type of AssuranceEvent
    ///   - payload: A dictionary representing the payload to be sent wrapped in the event. This will be serialized into JSON in the transportation process
    ///   - timestamp: optional argument representing the time original event was created. If not provided current time is taken
    ///   - vendor: vendor for the created `AssuranceEvent` defaults to "com.adobe.griffon.mobile".
    init(type: String, payload: [String: AnyCodable]?, timestamp: Date = Date(), vendor: String = AssuranceConstants.Vendor.MOBILE, metadata: [String: AnyCodable]? = nil) {
        self.type = type
        self.payload = payload
        self.timestamp = timestamp
        self.vendor = vendor
        self.eventNumber = AssuranceEvent.generateEventNumber()
        self.metadata = metadata
    }

    /// Returns the type of the command. Applies only for command events. This method returns nil for all other `AssuranceEvent`s.
    ///
    /// Returns nil if the event is not a command event.
    /// Returns nil if the payload does not contain "type" key.
    /// Returns nil if the payload "type" key contains non string data.
    ///
    /// Following are the currently available command recognized by Assurance SDK.
    ///  * startEventForwarding
    ///  * screenshot
    ///  * logForwarding
    ///  * fakeEvent
    ///  * configUpdate
    ///
    ///  Note : Commands are `AssuranceEvent` with type "control".
    ///  They are usually events generated from the Griffon UI demanding a specific action at the mobile client.
    ///
    /// - Returns: a string value representing the command (or) control type
    var commandType: String? {
        if AssuranceConstants.EventType.CONTROL != type {
            return nil
        }

        return payload?[AssuranceConstants.PayloadKey.TYPE]?.stringValue
    }

    /// Returns the details of the command. Applies only for command events. This method returns nil for all other `AssuranceEvent`s.
    ///
    /// Returns nil if the event is not a command event.
    /// Returns nil if the payload does not contain "type" key.
    /// Returns nil if the payload "type" key contains non string data.
    ///
    /// Note : Commands are `AssuranceEvent` with type "control".
    /// They are usually events generated from the Griffon UI demanding a specific action at the mobile client.
    ///
    /// - Returns: a dictionary representing the command details
    var commandDetails: [String: Any]? {
        if AssuranceConstants.EventType.CONTROL != type {
            return nil
        }

        return payload?[AssuranceConstants.PayloadKey.DETAIL]?.dictionaryValue
    }

    static private var eventNumberCounter: Int32 = 0
    private static func generateEventNumber() -> Int32 {
        OSAtomicIncrement32(&eventNumberCounter)
        return eventNumberCounter
    }

    public var description: String {
        // swiftformat:disable indent
        return "\n[\n" +
            "  id: \(eventID)\n" +
            "  type: \(type)\n" +
            "  vendor: \(vendor)\n" +
            "  payload: \(PrettyDictionary.prettify(payload))\n" +
            "  eventNumber: \(String(describing: eventNumber))\n" +
            "  timestamp: \(String(describing: timestamp?.description))\n" +
            "  metadata: \(PrettyDictionary.prettify(metadata))\n" +
            "]"
        // swiftformat:enable indent
    }

    var jsonData: Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return (try? encoder.encode(self)) ?? Data()
    }

}
