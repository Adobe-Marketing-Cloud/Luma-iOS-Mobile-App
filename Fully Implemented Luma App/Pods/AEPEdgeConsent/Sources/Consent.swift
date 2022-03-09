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

@objc(AEPMobileEdgeConsent)
public class Consent: NSObject, Extension {
    public let name = ConsentConstants.EXTENSION_NAME
    public let friendlyName = ConsentConstants.FRIENDLY_NAME
    public static let extensionVersion = ConsentConstants.EXTENSION_VERSION
    public let metadata: [String: String]? = nil
    public let runtime: ExtensionRuntime

    private var preferencesManager = ConsentPreferencesManager()

    // MARK: Extension

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
    }

    public func onRegistered() {
        registerListener(type: EventType.edgeConsent, source: EventSource.updateConsent, listener: receiveUpdateConsent(event:))
        registerListener(type: EventType.edgeConsent, source: EventSource.requestContent, listener: receiveRequestContent(event:))
        registerListener(type: EventType.edge,
                         source: ConsentConstants.EventSource.CONSENT_PREFERENCES,
                         listener: receiveEdgeConsentPreferenceHandle(event:))
        registerListener(type: EventType.configuration, source: EventSource.responseContent, listener: receiveConfigurationResponse(event:))

        // Share existing consents if they exist
        if preferencesManager.currentPreferences != nil {
            shareCurrentConsents(event: nil)
        }

        // If there is already a config shared state, attempt to read defaults
        if let configSharedState =
            getSharedState(extensionName: ConsentConstants.SharedState.Configuration.STATE_OWNER_NAME, event: nil),
           configSharedState.status == .set,
           let config = configSharedState.value {
            handleConfiguration(config: config, event: nil)
        }
    }

    public func onUnregistered() {}

    public func readyForEvent(_ event: Event) -> Bool {
        return true
    }

    // MARK: Event Listeners

    private func receiveConfigurationResponse(event: Event) {
        guard let config = event.data else { return }

        handleConfiguration(config: config, event: event)
    }

    /// Invoked when an event with `EventType.edgeConsent` and `EventSource.updateConsent` is dispatched by the `EventHub`
    /// - Parameter event: the consent update request
    private func receiveUpdateConsent(event: Event) {
        guard let consentsDict = event.data else {
            Log.debug(label: ConsentConstants.LOG_TAG, "Consent - Consent data not found in consent event request. Dropping event.")
            return
        }

        guard var newPreferences = ConsentPreferences.from(eventData: consentsDict) else {
            Log.debug(label: ConsentConstants.LOG_TAG, "Consent - Unable to decode consent data into a ConsentPreferences. Dropping event.")
            return
        }

        // set metadata
        newPreferences.setTimestamp(date: event.timestamp)
        preferencesManager.mergeAndUpdate(with: newPreferences)
        shareCurrentConsents(event: event)
        // Share only changed preferences instead of all preferences to prevent accidental sharing of default consents.
        dispatchEdgeConsentUpdateEvent(preferences: newPreferences)
    }

    /// Invoked when an event with `EventType.edge` and source `consent:preferences` is dispatched
    /// - Parameter event: the server-side consent preferences response event
    private func receiveEdgeConsentPreferenceHandle(event: Event) {
        guard let payload = event.data?[ConsentConstants.EventDataKeys.PAYLOAD] as? [Any] else {
            Log.debug(label: ConsentConstants.LOG_TAG, "Consent - consent:preferences handle missing payload. Dropping event.")
            return
        }

        let consentsDict = [ConsentConstants.EventDataKeys.CONSENTS: payload.first]
        guard var newPreferences = ConsentPreferences.from(eventData: consentsDict as [String: Any]) else {
            Log.debug(label: ConsentConstants.LOG_TAG,
                      "Consent - Unable to decode consent:preferences handle data into a ConsentPreferences. Dropping event.")
            return
        }

        if preferencesManager.mergeAndUpdate(with: newPreferences) {
            if newPreferences.consents[ConsentConstants.EventDataKeys.METADATA] == nil {
                // preferences were updated without providing metadata, update the metadata
                newPreferences.setTimestamp(date: event.timestamp)
                preferencesManager.mergeAndUpdate(with: newPreferences) // re-apply with updated metadata
            }

            shareCurrentConsents(event: event)
        }
    }

    /// Handles the get consent event and dispatches a response event with`EventType.edgeConsent` and `EventSource.responseContent`
    /// - Parameter event: the event requesting consents
    private func receiveRequestContent(event: Event) {
        let data = preferencesManager.currentPreferences?.asDictionary()
        let responseEvent = event.createResponseEvent(name: ConsentConstants.EventNames.GET_CONSENTS_RESPONSE,
                                                      type: EventType.edgeConsent,
                                                      source: EventSource.responseContent,
                                                      data: data)
        dispatch(event: responseEvent)
    }

    // MARK: Helpers

    /// Creates a new shared state with the newly updated preferences and dispatches an event
    /// with `EventType.edgeConsent` and `EventSource.responseContent` containing the updated preferences.
    ///
    /// - Parameters:
    ///   - event: the event for this consent update
    private func shareCurrentConsents(event: Event?) {
        let currentPreferencesDict = preferencesManager.currentPreferences?.asDictionary() ?? [:]
        // create shared state first, then dispatch response event
        createXDMSharedState(data: currentPreferencesDict, event: event)
        let responseEvent = Event(name: ConsentConstants.EventNames.CONSENT_PREFERENCES_UPDATED,
                                  type: EventType.edgeConsent,
                                  source: EventSource.responseContent,
                                  data: currentPreferencesDict)
        dispatch(event: responseEvent)
    }

    /// Dispatches event with `EventType.Edge` and `EventSource.updateConsent` with the new consent preferences represented as event data
    private func dispatchEdgeConsentUpdateEvent(preferences: ConsentPreferences) {
        let event = Event(name: ConsentConstants.EventNames.EDGE_CONSENT_UPDATE,
                          type: EventType.edge,
                          source: EventSource.updateConsent,
                          data: preferences.asDictionary())

        dispatch(event: event)
    }

    /// Takes in an SDK configuration and the default consents into the `PreferencesManager`. Will share updated consents if needed
    /// - Parameters:
    ///   - config: An SDK configuration
    ///   - event: optional `Event`
    private func handleConfiguration(config: [String: Any], event: Event?) {
        // fall back to empty default consents if not found in config
        let defaultPrefs = ConsentPreferences.from(config: config) ?? ConsentPreferences(consents: [:])

        if preferencesManager.updateDefaults(with: defaultPrefs) {
            shareCurrentConsents(event: event)
        }
    }
}
