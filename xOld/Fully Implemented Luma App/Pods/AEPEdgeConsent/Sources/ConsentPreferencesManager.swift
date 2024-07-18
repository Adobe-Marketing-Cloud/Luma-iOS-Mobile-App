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

/// The `ConsentPreferencesManager` is responsible for saving and loading consent preferences from persistence as well as merging existing consents with new consent
struct ConsentPreferencesManager {
    private let datastore = NamedCollectionDataStore(name: ConsentConstants.EXTENSION_NAME)

    /// Default preferences as received from Configuration update events
    private(set) var defaultPreferences: ConsentPreferences?

    /// Persisted preferences as set by the user via the Consent APIs and Konductor response events
    private(set) var persistedPreferences: ConsentPreferences? {
        get {
            let consentPreferences: ConsentPreferences? = datastore.getObject(key: ConsentConstants.DataStoreKeys.CONSENT_PREFERENCES)
            return consentPreferences
        }

        set {
            datastore.setObject(key: ConsentConstants.DataStoreKeys.CONSENT_PREFERENCES, value: newValue)
        }
    }

    /// The current user consent preferences merged over the default consent values (if any), used to be shared as Consent XDM Shared State and Consent response events.
    var currentPreferences: ConsentPreferences? {
        guard let persistedPreferences = persistedPreferences else {
            // No preferences in datastore, fallback to defaults if they exist
            return defaultPreferences
        }
        // Apply the persisted preferences on top of the default preferences
        return defaultPreferences?.merge(with: persistedPreferences) ?? persistedPreferences
    }

    /// Updates the existing persisted consent preferences with the passed in consent preferences.
    /// Duplicate keys will take the value of what is represented in the new consent preferences
    /// - Parameters:
    ///   - newPreferences: new consent preferences
    /// - Returns: True if the persisted preferences have changed, false if they have remained unmodified
    @discardableResult
    mutating func mergeAndUpdate(with newPreferences: ConsentPreferences) -> Bool {
        guard let persistedPreferences = persistedPreferences else {
            self.persistedPreferences = newPreferences
            return true
        }

        // Hold temp copy of what current consents are for comparison later
        let existingPreferences = currentPreferences
        // Update our persisted preferences
        self.persistedPreferences = persistedPreferences.merge(with: newPreferences)

        // Check if applying the new preferences would change the computed current preferences
        return existingPreferences != currentPreferences
    }

    /// Updates and replaces the existing default consent preferences with the passed in default consent preferences.
    /// - Parameter newDefaults: new default consent preferences
    /// - Returns: true if `currentConsents` has been updated as a result of updating the default consents
    mutating func updateDefaults(with newDefaults: ConsentPreferences) -> Bool {
        // Hold temp copy of what current consents are for comparison later
        let existingPreferences = currentPreferences
        // Update our default preferences
        self.defaultPreferences = newDefaults

        // Check if applying the new defaults would change the computed current preferences
        return existingPreferences != currentPreferences
    }
}
