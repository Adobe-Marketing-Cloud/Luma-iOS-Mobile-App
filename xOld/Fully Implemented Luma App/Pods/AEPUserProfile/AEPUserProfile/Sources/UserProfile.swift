/*
 Copyright 2020 Adobe. All rights reserved.
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

@objc(AEPMobileUserProfile)
public class UserProfile: NSObject, Extension {
    internal static let LOG_TAG = "UserProfile"

    private let dataStore: NamedCollectionDataStore
    private var attributes: [String: Any]

    // MARK: - Extension

    public let name = UserProfileConstants.EXTENSION_NAME
    public let friendlyName = UserProfileConstants.FRIENDLY_NAME
    public static let extensionVersion = UserProfileConstants.EXTENSION_VERSION
    public var metadata: [String: String]?
    public let runtime: ExtensionRuntime

    public required init(runtime: ExtensionRuntime) {
        self.runtime = runtime
        dataStore = NamedCollectionDataStore(name: UserProfileConstants.DATASTORE_NAME)
        attributes = [:]
        super.init()
    }

    public func onRegistered() {
        registerListener(type: EventType.userProfile, source: EventSource.requestProfile) { event in
            if event.isUpdateAttributesEvent {
                self.updateAttributes(event)
            } else if event.isGetAttributesEvent {
                self.getAttributes(event)
            } else {
                Log.trace(label: UserProfile.LOG_TAG, "Unable to process this event: \(event)")
            }
        }
        registerListener(type: EventType.userProfile, source: EventSource.requestReset, listener: removeAttributes(event:))
        registerListener(type: EventType.rulesEngine, source: EventSource.responseContent, listener: handleRulesEngineResponse(event:))
        loadAttributes()
        if let existingAttributes = UserProfileV5Migrator.existingAttributes() {
            Log.trace(label: UserProfile.LOG_TAG, "Data migration starts")
            attributes.merge(existingAttributes) { old, _ in old }
            persistAttributes()
            UserProfileV5Migrator.clearExistingAttributes()
        }
        createSharedState()
    }

    public func onUnregistered() {}

    public func readyForEvent(_: Event) -> Bool {
        true
    }

    // MARK: - Event Listeners

    /// Handles the `RulesEngine` response event
    /// - Parameter event: the RulesEngine response event
    private func handleRulesEngineResponse(event: Event) {
        guard event.isRulesConsequenceEvent, event.consequenceType == UserProfileConstants.RulesEngine.CONSEQUENCE_KEY_CSP else {
            Log.trace(label: UserProfile.LOG_TAG, "Unable to process this event: not a RulesEngine response event for UserProfile extension")
            return
        }
        switch event.detailOperation {
        case UserProfileConstants.RulesEngine.CONSEQUENCE_OPERATION_WRITE:
            if let key = event.detailKey, let value = event.detailValue {
                if value.isEmpty {
                    attributes.removeValue(forKey: key)
                    persistAttributes()
                    createSharedState(event: event)
                    Log.debug(label: UserProfile.LOG_TAG, "remove attribute: key = \(key); value = [empty String]")
                } else {
                    attributes.updateValue(value, forKey: key)
                    persistAttributes()
                    createSharedState(event: event)
                }

            } else {
                Log.debug(label: UserProfile.LOG_TAG, "Unable to process this event: operation = \(String(describing: event.detailOperation)); key = \(String(describing: event.detailKey)); value = \(String(describing: event.detailValue))")
            }
        case UserProfileConstants.RulesEngine.CONSEQUENCE_OPERATION_DELETE:
            if let key = event.detailKey {
                attributes.removeValue(forKey: key)
                persistAttributes()
                createSharedState(event: event)
            } else {
                Log.debug(label: UserProfile.LOG_TAG, "Unable to process this event: operation = \(String(describing: event.detailOperation)); key = \(String(describing: event.detailKey)); value = \(String(describing: event.detailValue))")
            }
        default:
            Log.debug(label: UserProfile.LOG_TAG, "Unable to process this event: operation = \(String(describing: event.detailOperation))")
        }
    }

    /// Handles  the `UserProfile`request event - update attributes
    /// - Parameter event: the request event
    private func updateAttributes(_ event: Event) {
        guard let newAttributes = event.data?[UserProfileConstants.UserProfile.EventDataKeys.UPDATE_DATA] as? [String: Any], !newAttributes.isEmpty else {
            Log.debug(label: UserProfile.LOG_TAG, "Unable to process the update attributes event: invalid event data")
            return
        }

        guard isPropertyListObject(object: newAttributes) else {
            Log.debug(label: UserProfile.LOG_TAG, "Unable to process the update attributes event: provided user attributes contain non-property-list objects")
            return
        }

        for (key, value) in newAttributes {
            switch value {
            case Optional<Any>.none:
                attributes.removeValue(forKey: key)
                Log.debug(label: UserProfile.LOG_TAG, "remove attribute: key = \(key); value = nil")
            default:
                if (value as? String)?.isEmpty ?? false {
                    attributes.removeValue(forKey: key)
                    Log.debug(label: UserProfile.LOG_TAG, "remove attribute: key = \(key); value = [empty String]")
                } else {
                    attributes.updateValue(value, forKey: key)
                    Log.debug(label: UserProfile.LOG_TAG, "update attribute: key = \(key); value = \(value)")
                }
            }
        }
        persistAttributes()

        createSharedState(event: event)
    }

    /// Handles  the `UserProfile`request event - get attributes
    /// - Parameter event: the request event
    private func getAttributes(_ event: Event) {
        guard let keys = event.data?[UserProfileConstants.UserProfile.EventDataKeys.GET_DATA_ATTRIBUTES] as? [String], !keys.isEmpty else {
            let errorMessage = "Unable to process the get attributes event: invalid event data"
            Log.debug(label: UserProfile.LOG_TAG, errorMessage)
            let responseEvent = event.createResponseEvent(name: "getUserAttributes", type: EventType.userProfile, source: EventSource.responseProfile, data: [UserProfileConstants.UserProfile.EventDataKeys.ERROR_RESPONSE: "", UserProfileConstants.UserProfile.EventDataKeys.ERROR_MESSAGE: errorMessage])
            dispatch(event: responseEvent)
            return
        }

        var data: [String: Any] = [:]
        for key in keys {
            data[key] = attributes[key]
        }
        let eventData = [UserProfileConstants.UserProfile.EventDataKeys.GET_DATA_ATTRIBUTES: data]
        let responseEvent = event.createResponseEvent(name: "getUserAttributes", type: EventType.userProfile, source: EventSource.responseProfile, data: eventData as [String: Any])
        dispatch(event: responseEvent)
    }

    /// Handles  the `UserProfile`request event - remove attributes
    /// - Parameter event: the request event
    private func removeAttributes(event: Event) {
        guard let keys = event.data?[UserProfileConstants.UserProfile.EventDataKeys.REMOVE_DATA] as? [String], !keys.isEmpty else {
            Log.debug(label: UserProfile.LOG_TAG, "Unable to process the remove attributes event: invalid event data")
            return
        }
        let attributesCount = attributes.count
        for key in keys {
            attributes.removeValue(forKey: key)
        }
        guard attributesCount != attributes.count else {
            Log.debug(label: UserProfile.LOG_TAG, "Unable to process the remove attributes event: no attributes matched with the given keys - \(keys)")
            return
        }
        persistAttributes()
        createSharedState(event: event)
    }

    // MARK: - Helpers

    private func loadAttributes() {
        if let storedAttributes = dataStore.getDictionary(key: UserProfileConstants.DATASTORE_KEY_ATTRIBUTES) as? [String: Any] {
            attributes.merge(storedAttributes) { _, new in new }
        } else {
            Log.debug(label: UserProfile.LOG_TAG, "Not found stored profile attributes")
        }
    }

    private func persistAttributes() {
        dataStore.set(key: UserProfileConstants.DATASTORE_KEY_ATTRIBUTES, value: attributes)
    }

    private func createSharedState(event: Event? = nil) {
        let sharedStateData = [UserProfileConstants.UserProfile.EventDataKeys.USERPROFILE_DATA: attributes]
        createSharedState(data: sharedStateData as [String: Any], event: event)
    }

    private func isPropertyListObject(object: Any) -> Bool {
        do {
            _ = try PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: PropertyListSerialization.WriteOptions())
            return true
        } catch {
            Log.debug(label: UserProfile.LOG_TAG, "\(object) is a non-property-list object ")
            return false
        }
    }
}
