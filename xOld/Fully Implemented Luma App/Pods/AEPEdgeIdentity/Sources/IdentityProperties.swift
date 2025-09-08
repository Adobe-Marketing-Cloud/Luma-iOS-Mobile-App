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

import AEPCore
import AEPServices
import Foundation

/// Represents a type which contains instances variables for this Identity extension
struct IdentityProperties: Codable {

    /// List of namespaces which are not allowed to be modified from customer identifier
    private static let reservedNamespaces = [
        IdentityConstants.Namespaces.ECID,
        IdentityConstants.Namespaces.IDFA,
        IdentityConstants.Namespaces.GAID
    ]

    /// The underlying IdentityMap structure which holds all the properties
    private(set) var identityMap: IdentityMap = IdentityMap()

    /// The current Experience Cloud ID
    var ecid: String? {
        get {
            return getPrimaryEcid()
        }

        set {
            // Remove previous ECID
            if let primaryEcid = getPrimaryEcid() {
                identityMap.remove(item: IdentityItem(id: primaryEcid), withNamespace: IdentityConstants.Namespaces.ECID)
            }

            // Update ECID if new is not empty
            if let newEcid = newValue, !newEcid.isEmpty {
                identityMap.add(item: IdentityItem(id: newEcid, authenticatedState: .ambiguous, primary: false),
                                withNamespace: IdentityConstants.Namespaces.ECID,
                                asFirstItem: true)

            } else {
                // If ECID is being removed, remove all other ECIDs as the primary ECID must be first in the list
                if let items = identityMap.getItems(withNamespace: IdentityConstants.Namespaces.ECID) {
                    for item in items {
                        identityMap.remove(item: item, withNamespace: IdentityConstants.Namespaces.ECID)
                    }
                    Log.debug(label: IdentityConstants.LOG_TAG, "IdentityProperties - Multiple ECID values found when clearing primary ECID. " +
                                "Primary ECID must be set to have secondary ECID values. ECID value(s) are cleared \(items)")
                }
            }
        }
    }

    /// The secondary Experience Cloud ID taken from the Identity direct extension
    var ecidSecondary: String? {
        get {
            return getSecondaryEcid()
        }

        set {
            // Remove previous ECID
            if let secondaryEcid = getSecondaryEcid() {
                identityMap.remove(item: IdentityItem(id: secondaryEcid), withNamespace: IdentityConstants.Namespaces.ECID)
            }

            guard getPrimaryEcid() != nil else {
                Log.debug(label: IdentityConstants.LOG_TAG, "IdentityProperties - Cannot set secondary ECID value as no primary ECID exists.")
                return
            }

            // Update ECID if new is not empty
            if let newEcid = newValue, !newEcid.isEmpty {
                identityMap.add(item: IdentityItem(id: newEcid, authenticatedState: .ambiguous, primary: false),
                                withNamespace: IdentityConstants.Namespaces.ECID)
            }
        }
    }

    /// The current Ad ID (IDFA) set with the Identity extension
    var advertisingIdentifier: String? {
        get {
            return getAdvertisingIdentifier()
        }

        set {
            // remove current Ad ID; there can be only one!
            if let currentAdId = getAdvertisingIdentifier() {
                identityMap.remove(item: IdentityItem(id: currentAdId), withNamespace: IdentityConstants.Namespaces.IDFA)
            }

            guard let newAdId = newValue, !newAdId.isEmpty else {
                return // new ID is nil or empty
            }

            // Update IDFA
            identityMap.add(item: IdentityItem(id: newAdId), withNamespace: IdentityConstants.Namespaces.IDFA)
        }
    }

    /// Merge the given `identifiersMap` with the current properties. Items in `identifiersMap` will overrite current properties where the `id` and
    /// `namespace` match. No items are removed. Identifiers under the namespaces "ECID" and "IDFA" are reserved and cannot be updated using this function.
    /// - Parameter identifiersMap: the `IdentityMap` to merge with the current properties
    mutating func updateCustomerIdentifiers(_ identifiersMap: IdentityMap) {
        removeIdentitiesWithReservedNamespaces(from: identifiersMap)
        identityMap.merge(map: identifiersMap)
    }

    /// Remove the given `identifiersMap` from the current properties.
    /// Identifiers under the namespaces "ECID" and "IDFA" are reserved and cannot be removed using this function.
    /// - Parameter identifiersMap: this `IdentityMap` with items to remove from the current properties
    mutating func removeCustomerIdentifiers(_ identifiersMap: IdentityMap) {
        removeIdentitiesWithReservedNamespaces(from: identifiersMap)
        identityMap.remove(map: identifiersMap)
    }

    /// Clear all identifiers
    mutating func clear() {
        identityMap = IdentityMap()
    }

    /// Converts `identityProperties` into an event data representation in XDM format
    /// - Parameter allowEmpty: If this `identityProperties` contains no data, return a dictionary with a single `identityMap` key
    /// to represent an empty IdentityMap when `allowEmpty` is true
    /// - Returns: A dictionary representing this `identityProperties` in XDM format
    func toXdmData(_ allowEmpty: Bool = false) -> [String: Any] {
        var map: [String: Any] = [:]

        // encode to event data
        if let dict = identityMap.asDictionary(), !dict.isEmpty || allowEmpty {
            map[IdentityConstants.XDMKeys.IDENTITY_MAP] = dict
        }

        return map
    }

    /// Populates the fields with values stored in the data store of this Identity extension
    mutating func loadFromPersistence() {
        let dataStore = NamedCollectionDataStore(name: IdentityConstants.DATASTORE_NAME)
        let savedProperties: IdentityProperties? = dataStore.getObject(key: IdentityConstants.DataStoreKeys.IDENTITY_PROPERTIES)

        if let savedProperties = savedProperties {
            self = savedProperties
        }
    }

    /// Saves this instance of `IdentityProperties` to the Identity data store
    func saveToPersistence() {
        let dataStore = NamedCollectionDataStore(name: IdentityConstants.DATASTORE_NAME)
        dataStore.setObject(key: IdentityConstants.DataStoreKeys.IDENTITY_PROPERTIES, value: self)
    }

    /// Load the ECID value from the Identity direct extension datastore if available.
    /// - Returns: `ECID` from the Identity direct extension datastore, or nil if the datastore or the ECID are not found
    func getEcidFromDirectIdentityPersistence() -> ECID? {
        let dataStore = NamedCollectionDataStore(name: IdentityConstants.SharedState.IdentityDirect.SHARED_OWNER_NAME)
        let identityDirectProperties: IdentityDirectProperties? = dataStore.getObject(key: IdentityConstants.DataStoreKeys.IDENTITY_PROPERTIES)
        return identityDirectProperties?.ecid
    }

    /// Get the primary ECID from the properties map.
    /// - Returns: the primary ECID or nil if a primary ECID was not found
    private func getPrimaryEcid() -> String? {
        guard let ecidList = identityMap.getItems(withNamespace: IdentityConstants.Namespaces.ECID) else {
            return nil
        }

        // the primary ecid is always the first in the list
        if let ecidItem = ecidList.first {
            return ecidItem.id
        }

        return nil
    }

    /// Get the secondary ECID from the properties map. It is assumed there is at most two ECID entries an the secondary ECID is the first non-primary id.
    /// If the primary and secondary ECID ids are the same, then only the primary ECID is set and this function will return nil.
    /// - Returns: the secondary ECID or nil if a secondary ECID was not found
    private func getSecondaryEcid() -> String? {
        guard let ecidList = identityMap.getItems(withNamespace: IdentityConstants.Namespaces.ECID) else {
            return nil
        }

        if ecidList.count > 1 {
            return ecidList[1].id
        }

        return nil
    }

    /// Get the advertising identifier from the properties map. Assumes only one `IdentityItem` under the "IDFA" namespace.
    /// - Returns: the advertising identifier or nil if not found
    private func getAdvertisingIdentifier() -> String? {
        guard let adIdList = identityMap.getItems(withNamespace: IdentityConstants.Namespaces.IDFA), !adIdList.isEmpty else {
            return nil
        }

        return adIdList[0].id
    }

    /// Filter out any items contained in reserved namespaces from the given `identityMap`.
    /// The list of reserved namespaces can be found at `reservedNamespaces`.
    /// - Parameter identifiersMap: the `IdentityMap` to filter out items contained in reserved namespaces.
    private func removeIdentitiesWithReservedNamespaces(from identifiersMap: IdentityMap) {
        // Filter out known identifiers to prevent modification of certain namespaces
        let filterItems = IdentityMap()
        for reservedNamespace in IdentityProperties.reservedNamespaces {
            for namespace in identifiersMap.namespaces where namespace.caseInsensitiveCompare(reservedNamespace) == .orderedSame {
                if let items = identifiersMap.getItems(withNamespace: namespace) {
                    if [IdentityConstants.Namespaces.IDFA, IdentityConstants.Namespaces.GAID].contains(namespace) {
                        let logMessage = "IdentityProperties - Operation not allowed for namespace '\(namespace)'; use MobileCore.setAdvertisingIdentifier instead."
                        Log.warning(label: IdentityConstants.LOG_TAG, logMessage)
                    } else {
                        Log.debug(label: IdentityConstants.LOG_TAG, "IdentityProperties - Adding/Updating identifiers in namespace '\(namespace)' is not allowed.")
                    }
                    for item in items {
                        filterItems.add(item: item, withNamespace: namespace)
                    }
                }
            }
        }

        if !filterItems.isEmpty {
            identifiersMap.remove(map: filterItems)
        }
    }
}

/// Helper structure which mimics the Identity Direct properties class. Used to decode the Identity Direct datastore.
private struct IdentityDirectProperties: Codable {
    var ecid: ECID?
}
