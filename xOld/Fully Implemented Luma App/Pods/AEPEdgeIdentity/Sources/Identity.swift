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

@objc(AEPMobileEdgeIdentity) public class Identity: NSObject, Extension {

    // MARK: Extension
    public let name = IdentityConstants.EXTENSION_NAME
    public let friendlyName = IdentityConstants.FRIENDLY_NAME
    public static let extensionVersion = IdentityConstants.EXTENSION_VERSION
    public let metadata: [String: String]? = nil
    private(set) var state: IdentityState

    public let runtime: ExtensionRuntime

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        state = IdentityState(identityProperties: IdentityProperties())
        super.init()
    }

    public func onRegistered() {
        registerListener(type: EventType.edgeIdentity, source: EventSource.requestIdentity, listener: handleIdentityRequest)
        registerListener(type: EventType.genericIdentity, source: EventSource.requestContent, listener: handleRequestContent)
        registerListener(type: EventType.edgeIdentity, source: EventSource.updateIdentity, listener: handleUpdateIdentity)
        registerListener(type: EventType.edgeIdentity, source: EventSource.removeIdentity, listener: handleRemoveIdentity)
        registerListener(type: EventType.genericIdentity, source: EventSource.requestReset, listener: handleRequestReset)
        registerListener(type: EventType.hub, source: EventSource.sharedState, listener: handleHubSharedState)
    }

    public func onUnregistered() {
    }

    public func readyForEvent(_ event: Event) -> Bool {
        guard state.bootupIfReady(getSharedState: getSharedState(extensionName:event:),
                                  createXDMSharedState: createXDMSharedState(data:event:)) else {
            return false
        }

        if event.urlVariables {
            return getSharedState(extensionName: IdentityConstants.SharedState.Configuration.SHARED_OWNER_NAME, event: event, resolution: .lastSet)?.value != nil
        }

        return true
    }

    // MARK: Event Listeners

    /// Handles events to set the advertising identifier. Called by listener registered with event hub.
    /// - Parameter event: event containing `advertisingIdentifier` data
    private func handleRequestContent(event: Event) {
        if event.isAdIdEvent {
            state.updateAdvertisingIdentifier(event: event,
                                              createXDMSharedState: createXDMSharedState(data:event:),
                                              eventDispatcher: dispatch(event:))
        }
    }

    /// Handles events requesting for identifiers. Dispatches response event containing the identifiers. Called by listener registered with event hub.
    /// - Parameter event: the identity request event
    private func handleIdentityRequest(event: Event) {
        if event.urlVariables {
            processGetUrlVariablesRequest(event: event)
        } else {
            processGetIdentifiersRequest(event: event)
        }
    }

    /// Handles events requesting for url variables. Dispatches response event containing the url variables string.
    /// - Parameter event: the identity request event
    func processGetUrlVariablesRequest(event: Event) {
        let emptyResponseEvent = event.createResponseEvent(name: IdentityConstants.EventNames.IDENTITY_RESPONSE_URL_VARIABLES,
                                                           type: EventType.edgeIdentity,
                                                           source: EventSource.responseIdentity,
                                                           data: [IdentityConstants.EventDataKeys.URL_VARIABLES: ""])

        guard let configurationSharedState = getSharedState(extensionName: IdentityConstants.SharedState.Configuration.SHARED_OWNER_NAME, event: event, resolution: .lastSet)?.value else {
            Log.warning(label: friendlyName, "\(#function) - Cannot process getUrlVariables request Identity event, configuration not found.")
            dispatch(event: emptyResponseEvent)
            return
        }

        // org id is required to process the URL variables request
        guard let orgId = configurationSharedState[IdentityConstants.ConfigurationKeys.EXPERIENCE_CLOUD_ORGID] as? String, !orgId.isEmpty else {
            Log.warning(label: friendlyName, "\(#function) - Cannot process getUrlVariables request Identity event, experienceCloud.org is invalid or missing in configuration.")
            dispatch(event: emptyResponseEvent)
            return
        }

        guard let ecid = state.identityProperties.ecid else {
            Log.warning(label: friendlyName, "\(#function) - Cannot process getUrlVariables request Identity event, ECID is nil or not yet generated by the SDK.")
            dispatch(event: emptyResponseEvent)
            return
        }
        let tsString = String(Int(Date().timeIntervalSince1970))
        let urlVariables = URLUtils.generateURLVariablesPayload(ts: tsString, ecid: ecid, orgId: orgId)

        let responseEvent = event.createResponseEvent(name: IdentityConstants.EventNames.IDENTITY_RESPONSE_URL_VARIABLES,
                                                      type: EventType.edgeIdentity,
                                                      source: EventSource.responseIdentity,
                                                      data: [IdentityConstants.EventDataKeys.URL_VARIABLES: urlVariables])

        // dispatch identity response event with shared state data
        dispatch(event: responseEvent)
    }

    /// Handles events requesting for identifiers. Dispatches response event containing the identifiers.
    /// - Parameter event: the identity request event
    func processGetIdentifiersRequest(event: Event) {
        // handle getECID or getIdentifiers API
        let xdmData = state.identityProperties.toXdmData(true)
        let responseEvent = event.createResponseEvent(name: IdentityConstants.EventNames.IDENTITY_RESPONSE_CONTENT_ONE_TIME,
                                                      type: EventType.edgeIdentity,
                                                      source: EventSource.responseIdentity,
                                                      data: xdmData)

        // dispatch identity response event with shared state data
        dispatch(event: responseEvent)
    }

    /// Handles update identity requests to add/update customer identifiers.
    /// - Parameter event: the identity request event
    private func handleUpdateIdentity(event: Event) {
        // Adding pending shared state to avoid race condition between updating and reading identity map
        let resolver = createPendingXDMSharedState(event: event)
        state.updateCustomerIdentifiers(event: event, resolveXDMSharedState: resolver)
    }

    /// Handles remove identity requests to remove customer identifiers.
    /// - Parameter event: the identity request event
    private func handleRemoveIdentity(event: Event) {
        // Adding pending shared state to avoid race condition between updating and reading identity map
        let resolver = createPendingXDMSharedState(event: event)
        state.removeCustomerIdentifiers(event: event, resolveXDMSharedState: resolver)
    }

    /// Handles `EventType.edgeIdentity` request reset events.
    /// - Parameter event: the identity request reset event
    private func handleRequestReset(event: Event) {
        // Adding pending shared state to avoid race condition between updating and reading identity map
        let resolver = createPendingXDMSharedState(event: event)
        state.resetIdentifiers(event: event,
                               resolveXDMSharedState: resolver,
                               eventDispatcher: dispatch(event:))
    }

    /// Handler for `EventType.hub` `EventSource.sharedState` events.
    /// If the state change event is for the Identity Direct extension, get the Identity Direct shared state, extract the ECID, and update the legacy ECID property.
    /// - Parameter event: shared state change event
    private func handleHubSharedState(event: Event) {
        guard let eventData = event.data,
              let stateowner = eventData[IdentityConstants.EventDataKeys.STATE_OWNER] as? String,
              stateowner == IdentityConstants.SharedState.IdentityDirect.SHARED_OWNER_NAME else {
            return
        }

        guard let identitySharedState = getSharedState(extensionName: IdentityConstants.SharedState.IdentityDirect.SHARED_OWNER_NAME, event: event)?.value else {
            return
        }

        // Get ECID. If doesn't exist then use empty string to clear legacy value
        let legacyEcid = identitySharedState[IdentityConstants.SharedState.IdentityDirect.VISITOR_ID_ECID] as? String ?? ""

        if state.updateLegacyExperienceCloudId(legacyEcid) {
            createXDMSharedState(data: state.identityProperties.toXdmData(), event: event)
        }
    }
}
