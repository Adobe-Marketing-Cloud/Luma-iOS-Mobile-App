//
//  MobileSDK.swift
//  Luma
//
//  Created by Rob In der Maur on 14/07/2023.
//

// import AEP MobileSDK libraries
import AEPCore
import AEPServices
import AEPIdentity
import AEPSignal
import AEPLifecycle
import AEPEdge
import AEPEdgeIdentity
import AEPEdgeConsent
import AEPUserProfile
import AEPPlaces
import AEPMessaging
import AEPOptimize
import AEPAssurance

import CoreLocation
import SwiftUI
import UserNotifications
import os.log

struct MobileSDK {
    // as we are requiring app do reinstall whenever we want to use new email and/or ecid
    // we just define all config values as global UserDefaults variables.
    @AppStorage("currentEcid") private var currentEcid: String = ""
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("currentEmailId") private var currentEmailId = "testUser@gmail.com"
    @AppStorage("currentCRMId") private var currentCRMId = "112ca06ed53d3db37e4cea49cc45b71e"
    @AppStorage("tenant") private var tenant = ""
    @AppStorage("sandbox") private var sandbox = ""
    @AppStorage("showProducts") private var showProducts: Bool = true
    @AppStorage("showPersonalisation") private var showPersonalisation: Bool = true
    @AppStorage("showPersonalisationDirect") private var showPersonalisationDirect: Bool = true
    @AppStorage("showGeofences") private var showGeofences:Bool = true
    @AppStorage("showBeacons") private var showBeacons: Bool = true
    @AppStorage("testPushEventType") private var testPushEventType = "application.test"
    @AppStorage("testPushOrchestrationId") private var testPushOrchestrationId = ""
    @AppStorage("brandName") private var brandName = "Luma"
    @AppStorage("brandLogo") private var brandLogo = "https://contentviewer.s3.amazonaws.com/helium/luma-logo01.png"
    @AppStorage("productsType") private var productsType = "Products"
    @AppStorage("productsSystemImage") private var productsSystemImage = "cart"
    @AppStorage("currency") private var currency = "$"
    @AppStorage("targetLocation") private var targetLocation = ""
    @AppStorage("ldap") private var ldap = ""
    @AppStorage("emailDomain") private var emailDomain = "adobetest.com"
    @AppStorage("tms") private var tms = ""
    @AppStorage("longitude") private var longitude = 0.0
    @AppStorage("latitude") private var latitude = 0.0
    @AppStorage("zoom") private var zoom = 2.0
    
    static let shared = MobileSDK()
    
    /// Load general configuration
    /// - Parameter configLocation: configLocation
    func loadGeneral(configLocation: String) async {
        let general = await Network.shared.loadGeneral(configLocation: configLocation)
        tenant = general.config.tenant
        sandbox = general.config.sandbox
        showProducts = general.config.showProducts
        showPersonalisation = general.config.showPersonalisation
        showPersonalisationDirect = general.config.showPersonalisationDirect ?? true
        showBeacons = general.config.showBeacons
        showGeofences = general.config.showGeofences
        brandName = general.customer.name
        brandLogo = general.customer.logo
        productsType = general.customer.productsType
        productsSystemImage = general.customer.productsSystemImage
        currency = general.customer.currency
        testPushEventType = general.testPush.eventType
        targetLocation = general.target.location
        ldap = general.config.ldap
        emailDomain = general.config.emailDomain ?? "adobetest.com"
        tms = general.config.tms
        longitude = general.map.longitude
        latitude = general.map.latitude
        zoom = general.map.zoom
    }
    
    /// Update consent
    /// - Parameter value: "y" or "n"
    func updateConsent(value: String) {
        // Update consent
        let collectConsent = ["collect": ["val": value]]
        let currentConsents = ["consents": collectConsent]
        Consent.update(with: currentConsents)
        MobileCore.updateConfigurationWith(configDict: currentConsents)
    }
    
    /// Get consents
    func getConsents() {
        // Get consents
        Consent.getConsents { consents, error in
            guard error == nil, let consents = consents else { return }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: consents, options: .prettyPrinted) else { return }
            guard let jsonStr = String(data: jsonData, encoding: .utf8) else { return }
            Logger.aepMobileSDK.info("Consent getConsents: \(jsonStr)")
        }
    }
    
    /// Send app interaction event
    /// - Parameter actionName: string identifying the action, e.g. "login"
    func sendAppInteractionEvent(actionName: String) {
        // Set up a data dictionary, create an experience event and send the event.
        let xdmData: [String: Any] = [
            //Page View
            "eventType": "application.interaction",
            tenant : [
                "appInformation": [
                    "appInteraction": [
                        "name": actionName,
                        "appAction": [
                            "value": 1
                        ]
                    ] as [String : Any]
                ]
            ]
        ]
        let appInteractionEvent = ExperienceEvent(xdm: xdmData)
        Edge.sendEvent(experienceEvent: appInteractionEvent)
    }
    
    /// Send track screen experience event
    /// - Parameter stateName: a string identifying the screen, e.g. "luma: content: ios: us: en: login"
    func sendTrackScreenEvent(stateName: String) {
        // Set up a data dictionary, create an experience event and send the event.
        let xdmData: [String: Any] = [
            "eventType": "application.scene",
            tenant : [
                "appInformation": [
                    "appStateDetails": [
                        "screenType": "App",
                        "screenName": stateName,
                        "screenView": [
                            "value": 1
                        ]
                    ] as [String : Any]
                ]
            ]
        ]
        let trackScreenEvent = ExperienceEvent(xdm: xdmData)
        Edge.sendEvent(experienceEvent: trackScreenEvent)
    }
    
    /// Sends an experienc event containing commerce and productListItems data
    /// - Parameters:
    ///   - commerceEventType: type of commerce event
    ///   - product: product object containing  details of the product selected
    func sendCommerceExperienceEvent(commerceEventType: String, product: Product) {
        // Set up a data dictionary, create an experience event and send the event.
        let xdmData: [String: Any] = [
            "eventType": "commerce." + commerceEventType,
            "commerce": [
                commerceEventType: [
                    "value": 1
                ] as [String : Any]
            ],
            "productListItems": [
                [
                    "name": product.name,
                    "priceTotal": product.price,
                    "SKU": product.sku
                ] as [String : Any]
            ]
        ]
        
        let commerceExperienceEvent = ExperienceEvent(xdm: xdmData)
        Edge.sendEvent(experienceEvent: commerceExperienceEvent)
    }
    
    /// Update identities wrapper function
    /// - Parameters:
    ///   - emailAddress: email address
    ///   - crmId: crmId
    func updateIdentities(emailAddress: String, crmId: String) {
        // Set up identity map, add identities to map and update identities
        let identityMap: IdentityMap = IdentityMap()
        
        let emailIdentity = IdentityItem(id: emailAddress, authenticatedState: AuthenticatedState.authenticated)
        let crmIdentity = IdentityItem(id: crmId, authenticatedState: AuthenticatedState.authenticated)
        identityMap.add(item:emailIdentity, withNamespace: "Email")
        identityMap.add(item: crmIdentity, withNamespace: "lumaCRMId")
        
        Identity.updateIdentities(with: identityMap)
    }
    
    /// Remove identities wrapper function
    /// - Parameters:
    ///   - emailAddress: email address
    ///   - crmId: crmID
    func removeIdentities(emailAddress: String, crmId: String) {
        // Remove identities and reset email and CRM Id to their defaults
        Identity.removeIdentity(item: IdentityItem(id: emailAddress), withNamespace: "Email")
        Identity.removeIdentity(item: IdentityItem(id: crmId), withNamespace: "lumaCRMId")
        currentEmailId = "testUser@gmail.com"
        currentCRMId = "112ca06ed53d3db37e4cea49cc45b71e"
    }
    
    /// Wrapper function to fetch identities
    func getIdentities() {
        AEPIdentity.Identity.getExperienceCloudId { ecid, error in
            if ecid == nil {
                if let error = error {
                    Logger.aepMobileSDK.error("MobileSDK - getIdentities: NO ECID…:  \(error.localizedDescription)…")
                }
                return
            }
            currentEcid = ecid ?? ""
        }
        Identity.getIdentities { identityMap, error in
            if let currentIdentityMap = identityMap  {
                if let items: [IdentityItem] = currentIdentityMap.getItems(withNamespace: "email") {
                    currentEmailId = items.last?.id ?? "testUser@gmail.com"
                }
            }
        }
    }
    
    /// Wrapper function to update user attribute
    /// - Parameters:
    ///   - attributeName: attribute name
    ///   - attributeValue: attribute value
    func updateUserAttribute(attributeName: String, attributeValue: String) {
        // Create a profile map, add attributes to the map and update profile using the map
        var profileMap = [String: Any]()
        profileMap[attributeName] = attributeValue
        UserProfile.updateUserAttributes(attributeDict: profileMap)
    }
    
    /// Send test push event using a TestPushPayload struct
    /// - Parameters:
    ///   - applicationId: application identifier
    ///   - eventType: event type
    func sendTestPushEvent(applicationId: String, eventType: String) async {
        // Create payload and send experience event
        Task {
            let testPushPayload = TestPushPayload(
                application: Application(
                    id: applicationId
                ),
                eventType: eventType
            )
            // send the final experience event
            await sendExperienceEvent(
                xdm: testPushPayload.asDictionary() ?? [:]
            )
        }
    }
    
    @MainActor
    /// Sends the actual experience event
    /// - Parameters:
    ///   - xdm: the XDM repesentation of the event payload as a dictionary
    func sendExperienceEvent(xdm: [String: Any]) async {
        // create experience event from payload
        let experienceEvent = ExperienceEvent(xdm: xdm)
        // send experience event
        Edge.sendEvent(experienceEvent: experienceEvent) { (handles: [EdgeEventHandle]) in
            for handle in handles {
                if handle.payload != nil {
                    Logger.aepMobileSDK.info("MobileSDK - sendExperienceEvent: Handle type: \(handle.type ?? "")")
                }
            }
        }
    }
    
    @MainActor
    /// Sends track action to kick off arule defined in AEP Data Collection or trigger a campaign in AJO
    /// - Parameters:
    ///   - action: action
    ///   - data: data
    func sendTrackAction(action: String, data: [String: Any]?) {
        // Send trackAction event
        MobileCore.track(action: action, data: data)
    }
    
    @MainActor
    /// Update propositions for AT
    /// - Parameters:
    ///   - ecid: ECID
    ///   - location: Target location
    func updatePropositionsAT(ecid: String, location: String) async {
        // set up the XDM dictionary, define decision scope and call update proposition API
        Task {
            let ecid = ["ECID" : ["id" : ecid, "primary" : true] as [String : Any]]
            let identityMap = ["identityMap" : ecid]
            let xdmData = ["xdm" : identityMap]
            let decisionScope = DecisionScope(name: location)
            Optimize.clearCachedPropositions()
            Optimize.updatePropositions(for: [decisionScope], withXdm: xdmData)
        }
    }
    
    /// Update proposition for OD
    /// - Parameters:
    ///   - ecid: ECID
    ///   - decisionScopes: decisionScopes
    func updatePropositionsOD(ecid: String, activityId: String, placementId: String, itemCount: Int) async {
        // set up the XDM dictionary, define decision scope and call update proposition API
        Task {
            let ecid = ["ECID" : ["id" : ecid, "primary" : true] as [String : Any]]
            let identityMap = ["identityMap" : ecid]
            let xdmData = ["xdm" : identityMap]
            let decisionScope = DecisionScope(activityId: activityId, placementId: placementId, itemCount: UInt(itemCount))
            Optimize.clearCachedPropositions()
            Optimize.updatePropositions(for: [decisionScope], withXdm: xdmData)
        }
    }
    
    /// Request offers directly from AJO - OD, not though edge
    /// - Parameters:
    ///   - ecid: ECID
    ///   - containerId: id identifiying  container
    ///   - accessToken: access token from configuration
    ///   - apiKey: api key from configuration
    ///   - orgId: org id from configuration
    ///   - allowDuplicatesAcrossActivities: flag to allow duplicates across activities
    ///   - allowDuplicatesAcrossPlacements: flag to allow duplicates across placements
    ///   - dryRun: flag to toggle dryRun or not
    ///   - decisionScopes: decision scopes
    /// - Returns: proposition array
    func requestDirectOffers(
        ecid: String,
        containerId: String,
        accessToken: String,
        apiKey: String,
        orgId: String,
        allowDuplicatesAcrossActivities: Bool,
        allowDuplicatesAcrossPlacements: Bool,
        dryRun: Bool,
        decisionScopes: [Decision]
    ) async -> [Proposition] {
        var propositionRequests: [XDMPropositionRequest] = []
        var jsonString = ""
        
        // set up proposition requests based on content of decisions from json config file
        for decisionScope in decisionScopes {
            let propositionRequest = XDMPropositionRequest(
                xdmPlacementID: decisionScope.placementId,
                xdmActivityID: decisionScope.activityId,
                xdmItemCount: decisionScope.itemCount
            )
            propositionRequests.append(propositionRequest)
        }
        
        // complete the payload with other parameters required for request
        let decisionRequestPayload = DecisionRequestPayload(
            xdmPropositionRequests: propositionRequests,
            xdmProfiles: [XDMProfile(xdmIdentityMap: XDMIdentityMap(ecid: [Ecid(xdmID: currentEcid)]))],
            xdmAllowDuplicatePropositions: XDMAllowDuplicatePropositions(
                xdmAcrossActivities: allowDuplicatesAcrossActivities,
                xdmAcrossPlacements: allowDuplicatesAcrossPlacements
            ),
            xdmResponseFormat: XDMResponseFormat(xdmIncludeContent: true),
            xdmIncludeMetadata: XDMIncludeMetadata(xdmActivity: ["name"], xdmOption: ["name"], xdmPlacement: ["name"]),
            xdmDryRun: dryRun
        )
        
        do {
            let jsonData = try JSONEncoder().encode(decisionRequestPayload)
            jsonString = String(data: jsonData, encoding: .utf8)!
        }
        catch {
            Logger.aepDirectAPI.error("MobileSDK - requestDirectOffers: Error getting struct encoded to JSON: \(error.localizedDescription)…")
            return [Proposition]()
        }
        
        let postData = jsonString.data(using: .utf8)
        
        // build up the request
        var request = URLRequest(url: URL(string: "https://platform.adobe.io/data/core/ode/\(containerId)/decisions")!, timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue(orgId, forHTTPHeaderField: "x-gw-ims-org-id")
        request.addValue("unique-requestid-\(apiKey)", forHTTPHeaderField: "x-request-id")
        request.addValue("application/vnd.adobe.xdm+json; schema=\"https://ns.adobe.com/experience/offer-management/decision-request;version=1.0\"", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.adobe.xdm+json; schema=\"https://ns.adobe.com/experience/offer-management/decision-response;version=1.0\"", forHTTPHeaderField: "Accept")
        request.addValue(sandbox, forHTTPHeaderField: "x-sandbox-name")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // ensure we do not do any caching
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: config)
        
        // send and handle the decision request
        if let (data, _) = try? await session.data(for: request) {
            do {
                let decisionResponse = try JSONDecoder().decode(DecisionResponse.self, from: data)
                Logger.aepDirectAPI.info("MobileSDK - requestDirectOffers: DecisionResponse propositionId: \(decisionResponse.propositionId)")
                Logger.aepDirectAPI.info("MobileSDK - requestDirectOffers: DecisionResponse prositions \(decisionResponse.propositions.count)")
                return decisionResponse.propositions
                
            }
            catch {
                Logger.aepDirectAPI.error("MobileSDK - requestDirectOffers: DecisionResponse: \(error.localizedDescription)…")
                return [Proposition]()
            }
        }
        else {
            return [Proposition]()
        }
    }
    
    @MainActor
    /// Process region event
    /// - Parameters:
    ///   - regionEvent: region event, such as .entry or .exit
    ///   - region: CLRegion
    func processRegionEvent(regionEvent: PlacesRegionEvent, forRegion region: CLRegion) async {
        // Process geolocation event
        Places.processRegionEvent(regionEvent, forRegion: region)
    }
    
    @MainActor
    /// Sends beacon event
    /// - Parameters:
    ///   - ecid: ECID
    ///   - eventType: event type, e.g. beacon.entry or beacon.exit
    ///   - name: name of POI
    ///   - id: id of POI
    ///   - city: city of POI
    func sendBeaconEvent(ecid: String, eventType: String, name: String, id: String, category: String, beaconMajor: Double, beaconMinor: Double) async {
        Task {
            // create the payload
            let beaconEventPayload = BeaconInteractionPayload(
                placeContext: PlaceContext(
                    poIinteraction: POIinteraction(
                        poiDetail: PoiDetail(
                            name: name,
                            poiID: id,
                            locatingType: "beacon",
                            category: category,
                            beaconInteractionDetails: BeaconInteractionDetails(
                                beaconMajor: beaconMajor,
                                beaconMinor: beaconMinor)
                        ),
                        poiEntries: PoiEntries(
                            value: eventType == "location.entry" ? 1 : 0
                        ),
                        poiExits: PoiExits(
                            value: eventType == "location.exit" ? 1 : 0
                        )
                    )
                ),
                eventType: eventType
            )
            
            // send the final experience event
            await sendExperienceEvent(
                xdm: beaconEventPayload.asDictionary() ?? [:]
            )
        }
    }
    
    func getAccessToken() async -> String {
        let data = NSMutableData(data: "grant_type=client_credentials".data(using: .utf8)!)
        data.append("&client_id=9efb3375a9ac485db347ba6315877e88".data(using: .utf8)!)
        data.append("&client_secret=p8e-Wa3MyxPjSnUcif3ElbTl43wZsJ5Ulpen".data(using: .utf8)!)
        data.append("&scope=openid,session,cjm.suppression_service.client.delete,AdobeID,read_organizations,cjm.suppression_service.client.all,additional_info.projectedProductContext".data(using: .utf8)!)

        let url = URL(string: "https://ims-na1.adobelogin.com/ims/token/v3")!
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data as Data
        
        // ensure we do not do any caching
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: config)
        
        // send and handle the decision request
        if let (data, _) = try? await session.data(for: request) {
            do {
                let accessTokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                let accessToken = accessTokenResponse.accessToken
                Logger.aepDirectAPI.info("MobileSDK - getAccessToken: \(accessToken)")
                return accessToken
            }
            catch {
                Logger.aepDirectAPI.error("MobileSDK - getAccessToken: \(error.localizedDescription)…")
                return ""
            }
        }
        else {
            return ""
        }
    }
}
