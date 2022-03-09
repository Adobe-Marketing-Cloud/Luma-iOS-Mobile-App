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

/// `PluginHub`  is responsible for registering and maintaining `AssurancePlugin`s.
///  It is responsible for delivering the Assurance command events directed for those registered plugins.
///  It also notifies the plugins about the on going `AssuranceSession` status
///
/// @see AssurancePlugin
class PluginHub {
    let pluginCollection = ThreadSafeDictionary<Int, ThreadSafeArray<AssurancePlugin>>(identifier: "com.adobe.assurance.pluginCollection")

    /// Registers the provided `AssurancePlugin` to receive command
    /// Calls the `onRegistered` protocol method on successful registration
    /// - Parameters:
    ///   - plugin: instance of the plugin to be registered
    ///   - session: the `AssuranceSession` to which the plugin is registered
    func registerPlugin(_ plugin: AssurancePlugin, toSession session: AssuranceSession) {
        let vendorHash = plugin.vendor.hash
        var pluginVendorArray = pluginCollection[vendorHash]

        if pluginVendorArray == nil {
            pluginVendorArray = ThreadSafeArray<AssurancePlugin>()
            pluginCollection[vendorHash] = pluginVendorArray
        }

        pluginVendorArray?.append(plugin)
        plugin.onRegistered(session)
    }

    /// Notifies all the registered plugins about the successful connection establishment with Assurance session.
    func notifyPluginsOfEvent(_ event: AssuranceEvent) {
        guard let pluginsForVendor = pluginCollection[event.vendor.hash] else {
            return
        }

        for i in 0...(pluginsForVendor.count - 1) {
            let plugin = pluginsForVendor[i]

            // if the plugin matches control type of the event. Send the event to that plugin
            if plugin.commandType.lowercased() == AssuranceConstants.CommandType.WILDCARD || plugin.commandType.lowercased() == event.commandType?.lowercased() {
                plugin.receiveEvent(event)
            }
        }
    }

    /// Notifies all the registered plugins about the successful connection establishment with Assurance session.
    func notifyPluginsOnConnect() {
        getEachRegisteredPlugin({ plugin in
            plugin.onSessionConnected()
        })
    }

    /// Notifies all the registered plugins about disconnection with Assurance session.
    /// - Parameter :
    ///     - closeCode: Integer representing the reason for socket disconnection
    func notifyPluginsOnDisconnect(withCloseCode closeCode: Int) {
        getEachRegisteredPlugin({ plugin in
            plugin.onSessionDisconnectedWithCloseCode(closeCode)
        })
    }

    /// Notifies all the registered plugins about connection termination with Assurance session.
    func notifyPluginsOnSessionTerminated() {
        getEachRegisteredPlugin({ plugin in
            plugin.onSessionTerminated()
        })
    }

    // MARK: Private methods

    /// Helper function to iterate through all the registered plugins.
    /// The callback is called multiple times with each registered plugin.
    private func getEachRegisteredPlugin(_ callback: (AssurancePlugin) -> Void) {
        for pluginVendor in pluginCollection.keys {
            guard let threadSafePluginsArray = pluginCollection[pluginVendor] else {
                return
            }

            for i in 0...(threadSafePluginsArray.count - 1) {
                let plugin = threadSafePluginsArray[i]
                callback(plugin)
            }
        }
    }
}
