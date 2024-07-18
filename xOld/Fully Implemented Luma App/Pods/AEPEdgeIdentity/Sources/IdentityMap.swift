//
// Copyright 2021 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import AEPServices
import Foundation

/// The state this identity is authenticated.
/// - ambiguous - Ambiguous.
/// - authenticated - User identified by a login or similar action that was valid at the time of the event observation.
/// - loggedOut - User was identified by a login action at some point of time previously, but is not currently logged in.
@objc(AEPAuthenticatedState)
public enum AuthenticatedState: Int, RawRepresentable, Codable {
    case ambiguous = 0
    case authenticated = 1
    case loggedOut = 2

    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .ambiguous:
            return IdentityConstants.AuthenticatedStates.AMBIGUOUS
        case .authenticated:
            return IdentityConstants.AuthenticatedStates.AUTHENTICATED
        case .loggedOut:
            return IdentityConstants.AuthenticatedStates.LOGGED_OUT
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case IdentityConstants.AuthenticatedStates.AMBIGUOUS:
            self = .ambiguous
        case IdentityConstants.AuthenticatedStates.AUTHENTICATED:
            self = .authenticated
        case IdentityConstants.AuthenticatedStates.LOGGED_OUT:
            self = .loggedOut
        default:
            self = .ambiguous
        }
    }
}

/// Defines a map containing a set of end user identities, keyed on either namespace integration code or the namespace ID of the identity.
/// Within each namespace, the identity is unique. The values of the map are an array, meaning that more than one identity of each namespace may be carried.
@objc(AEPIdentityMap)
public class IdentityMap: NSObject, Codable {
    private var items: [String: [IdentityItem]] = [:]

    /// Determines if this `IdentityMap` has no identities.
    @objc public var isEmpty: Bool {
        return items.isEmpty
    }

    /// A list of all namespaces used in this `IdentityMap`.
    @objc public var namespaces: [String] {
        return items.map({$0.key})
    }

    public override init() {}

    /// Adds an `IdentityItem` to this map. If an item is added which shares the same `withNamespace` and `item.id` as an item
    /// already in the map, then the new item replaces the existing item. Empty `withNamespace` or items with an empty `item.id` are not allowed and are ignored.
    /// - Parameters:
    ///   - item: The identity as an `IdentityItem` object
    ///   - withNamespace: The namespace for this identity
    @objc(addItem:withNamespace:)
    public func add(item: IdentityItem, withNamespace: String) {
        add(item: item, withNamespace: withNamespace, asFirstItem: false)
    }

    /// Remove a single `IdentityItem` from this map.
    /// - Parameters:
    ///   - item: The identity to remove from the given `withNamespace`
    ///   - withNamespace: The namespace for the identity to remove
    @objc(removeItem:withNamespace:)
    public func remove(item: IdentityItem, withNamespace: String) {
        guard var namespaceItems = items[withNamespace], let index = namespaceItems.firstIndex(of: item) else {
            return
        }

        namespaceItems.remove(at: index)

        if namespaceItems.isEmpty {
            items.removeValue(forKey: withNamespace)
        } else {
            items[withNamespace] = namespaceItems
        }
    }

    /// Get the array of `IdentityItem`(s) for the given namespace.
    /// - Parameter withNamespace: the namespace of items to retrieve
    /// - Returns: An array of `IdentityItem`s for the given `withNamespace` or nil if this `IdentityMap` does not contain the `withNamespace`.
    @objc(getItemsWithNamespace:)
    public func getItems(withNamespace: String) -> [IdentityItem]? {
        return items[withNamespace]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(items)
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.singleValueContainer()
        if let identityItems = try? container.decode([String: [IdentityItem]].self) {
            for (namespace, items) in identityItems {
                for item in items {
                    self.add(item: item, withNamespace: namespace)
                }
            }
        }
    }

    /// Append an `IdentityItem` to this map, with option to insert at the front of items list.
    /// If an item is added which shares the same `withNamespace` and `item.id` as an item already in the map, then the new item replaces
    /// the existing item. Empty `withNamespace` or items with an empty `item.id` are not allowed and are ignored.
    /// - Parameters:
    ///   - item: The identity as an `IdentityItem` object
    ///   - namespace: The namespace for this identity
    ///   - asFirstItem: if true, `IdentityItem` is added as the first element in the list, otherwise it is appended to the end of the list
    func add(item: IdentityItem, withNamespace: String, asFirstItem: Bool) {
        if item.id.isEmpty || withNamespace.isEmpty {
            Log.debug(label: IdentityConstants.LOG_TAG, "IdentityMap - Ignoring add:item:withNamespace, empty identifiers and namespaces are not allowed.")
            return
        }

        if var namespaceItems = items[withNamespace] {
            if let index = namespaceItems.firstIndex(of: item) {
                namespaceItems[index] = item
            } else {
                let insertIndex = asFirstItem ? 0 : namespaceItems.endIndex
                namespaceItems.insert(item, at: insertIndex)
            }
            items[withNamespace] = namespaceItems
        } else {
            items[withNamespace] = [item]
        }
    }

    /// Merge `map` on to this `IdentityMap`. Any `IdentityItem` in `map` which shares the same
    /// namespace and id as an item in this `IdentityMap` will replace that `IdentityItem`.
    /// - Parameter map: an `IdentityMap` to add onto this `IdentityMap`
    func merge(map: IdentityMap) {
        for (namespace, items) in map.items {
            for item in items {
                self.add(item: item, withNamespace: namespace)
            }
        }
    }

    /// Remove identities in `map` from this `IdentityMap`. Identities are removed which match the same namesapce and id.
    /// - Parameter map: Identities to remove from this `IdentityMap`
    func remove(map: IdentityMap) {
        for (namespace, items) in map.items {
            for item in items {
                self.remove(item: item, withNamespace: namespace)
            }
        }
    }

    /// Decodes a `[String: Any]` dictionary into an `IdentityMap`
    /// - Parameter eventData: the event data representing `IdentityMap`
    /// - Returns: an `IdentityMap` that is represented in the event data, nil if data is not in the correct format
    static func from(eventData: [String: Any]) -> IdentityMap? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: eventData) else {
            Log.debug(label: IdentityConstants.LOG_TAG, "IdentityMap - Unable to serialize identity event data.")
            return nil
        }

        guard let identityMap = try? JSONDecoder().decode(IdentityMap.self, from: jsonData) else {
            Log.debug(label: IdentityConstants.LOG_TAG, "IdentityMap - Unable to decode identity data into an IdentityMap.")
            return nil
        }

        return identityMap
    }

}

/// Identity is used to clearly distinguish people that are interacting with digital experiences.
@objc(AEPIdentityItem)
@objcMembers
public class IdentityItem: NSObject, Codable {
    public let id: String
    public let authenticatedState: AuthenticatedState
    public let primary: Bool

    /// Creates a new `IdentityItem`.
    /// - Parameters:
    ///   - id: Identity of the consumer in the related namespace.
    ///   - authenticatedState: The state this identity is authenticated as. Default is 'ambiguous'.
    ///   - primary: Indicates this identity is the preferred identity. Is used as a hint to help systems better organize how identities are queried. Default is false.
    public init(id: String, authenticatedState: AuthenticatedState = .ambiguous, primary: Bool = false) {
        self.id = id
        self.authenticatedState = authenticatedState
        self.primary = primary
    }

    /// Defines two `IdentityItem` objects are equal if they have the same `id`.
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? IdentityItem else { return false }
        return self.id == object.id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authenticatedState
        case primary
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(String.self, forKey: .id)

        if let state = try? values.decode(AuthenticatedState.self, forKey: .authenticatedState) {
            self.authenticatedState = state
        } else {
            self.authenticatedState = .ambiguous
        }

        if let primaryId = try? values.decode(Bool.self, forKey: .primary) {
            self.primary = primaryId
        } else {
            self.primary = false
        }
    }
}
