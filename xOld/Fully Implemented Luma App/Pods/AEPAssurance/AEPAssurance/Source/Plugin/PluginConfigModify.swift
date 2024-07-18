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

/// Plugin that acts on command to modify configuration of the Mobile SDK
///
/// The plugin gets invoked with Assurance command event having
/// - vendor  : "com.adobe.griffon.mobile"
/// - command type   : "configUpdate"
///
/// This plugin gets registered with `PluginHub`during the registration of Assurance extension.
/// Once a command to modify configuration is received. This plugin extracts the configuration details from the command, and uses
/// the `MobileCore.updateConfiguration` API to modify the demanded configuration from the connected  assurance session.
/// The modified configuration keys are stored in datastore, hence when assurance session is terminated the modified configuration is
/// reverted back.
class PluginConfigModify: AssurancePlugin {

    weak var session: AssuranceSession?

    let datastore = NamedCollectionDataStore(name: AssuranceConstants.EXTENSION_NAME)

    // property that returns the previously modified configuration keys from datastore
    var modifiedConfigKeys: [String] {
        datastore.getArray(key: AssuranceConstants.DataStoreKeys.CONFIG_MODIFIED_KEYS) as? [String] ?? []
    }

    // MARK: - AssurancePlugin protocol properties

    var vendor: String = AssuranceConstants.Vendor.MOBILE

    var commandType: String = AssuranceConstants.CommandType.CONFIG_UPDATE

    // MARK: - AssurancePlugin protocol methods

    /// Delegate method called when a command is received to modify the configuration of Mobile SDK
    /// - Parameter event  An `AssuranceEvent` that contains the details about the configuration that need to be modified
    func receiveEvent(_ event: AssuranceEvent) {
        guard let commandDetails = event.commandDetails else {
            Log.debug(label: AssuranceConstants.LOG_TAG, "PluginConfigUpdate - Command details empty. Assurance SDK is ignoring the command to update configuration.")
            return
        }

        MobileCore.updateConfigurationWith(configDict: commandDetails)
        var logString = "Configuration updated for \(commandDetails.count > 1 ? "keys" : "key")"
        for (configKey) in commandDetails.keys {
            logString.append("<br> &emsp; \(configKey)")
        }
        session?.statusUI.addClientLog(logString, visibility: .high)
        saveModifiedConfigKeys(commandDetails)
    }

    /// Delegate method called when assurance session from this mobile device is terminated
    /// Handles the operation to revert the modified configuration that has been changed during the assurance session.
    func onSessionTerminated() {
        var configData: [String: Any] = [:]

        for key in modifiedConfigKeys {
            // setting the configuration parameter to NSNull will remove the programmatically overridden config value.
            configData[key] = NSNull()
        }

        if !configData.isEmpty {
            MobileCore.updateConfigurationWith(configDict: configData)
            clearModifiedKeys()
        }
    }

    /// protocol method is called from this Plugin is registered with `PluginHub`
    func onRegistered(_ session: AssuranceSession) {
        self.session = session
    }

    // no op - protocol methods
    func onSessionConnected() {}

    func onSessionDisconnectedWithCloseCode(_ closeCode: Int) {}

    // MARK: - Private functions

    private func saveModifiedConfigKeys(_ modifiedConfig: [String: Any]?) {
        // bail out if there are no modified configuration
        guard let modifiedConfig = modifiedConfig else {
            return
        }

        // create a `Set` for previously modified configuration keys
        // using Swift's unordered collection `Set` to remove duplication of configuration keys
        var uniqueKeys = Set(modifiedConfigKeys)

        // loop through the modified configuration dictionary and add the unique keys to the set
        for (key, _) in modifiedConfig {
            uniqueKeys.insert(key)
        }

        // save the new set of appended modified keys to the datastore
        datastore.set(key: AssuranceConstants.DataStoreKeys.CONFIG_MODIFIED_KEYS, value: Array(uniqueKeys))
    }

    // Use this method to clear the modified configuration keys in the datastore
    private func clearModifiedKeys() {
        datastore.remove(key: AssuranceConstants.DataStoreKeys.CONFIG_MODIFIED_KEYS)
    }

}
