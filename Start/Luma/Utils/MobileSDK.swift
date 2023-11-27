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
        
    }
    
    /// Get consents
    func getConsents() {
        // Get consents
        
    }
    
    /// Send app interaction event
    /// - Parameter actionName: string identifying the action, e.g. "login"
    func sendAppInteractionEvent(actionName: String) {
        // Set up a data dictionary, create an experience event and send the event.
        
    }
    
    /// Send track screen experience event
    /// - Parameter stateName: a string identifying the screen, e.g. "luma: content: ios: us: en: login"
    func sendTrackScreenEvent(stateName: String) {
        // Set up a data dictionary, create an experience event and send the event.
        
    }
    
    /// Sends an experienc event containing commerce and productListItems data
    /// - Parameters:
    ///   - commerceEventType: type of commerce event
    ///   - product: product object containing  details of the product selected
    func sendCommerceExperienceEvent(commerceEventType: String, product: Product) {
        // Set up a data dictionary, create an experience event and send the event.
        
    }
    
    /// Update identities wrapper function
    /// - Parameters:
    ///   - emailAddress: email address
    ///   - crmId: crmId
    func updateIdentities(emailAddress: String, crmId: String) {
        // Set up identity map, add identities to map and update identities
        
    }
    
    /// Remove identities wrapper function
    /// - Parameters:
    ///   - emailAddress: email address
    ///   - crmId: crmID
    func removeIdentities(emailAddress: String, crmId: String) {
        // Remove identities and reset email and CRM Id to their defaults
        
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
        
    }
    
    /// Send test push event using a TestPushPayload struct
    /// - Parameters:
    ///   - applicationId: application identifier
    ///   - eventType: event type
    func sendTestPushEvent(applicationId: String, eventType: String) async {
        // Create payload and send experience event
        
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
        
    }
    
    @MainActor
    /// Update propositions for AT
    /// - Parameters:
    ///   - ecid: ECID
    ///   - location: Target location
    func updatePropositionsAT(ecid: String, location: String) async {
        // set up the XDM dictionary, define decision scope and call update proposition API
        
    }
    
    /// Update proposition for OD
    /// - Parameters:
    ///   - ecid: ECID
    ///   - decisionScopes: decisionScopes
    func updatePropositionsOD(ecid: String, activityId: String, placementId: String, itemCount: Int) async {
        // set up the XDM dictionary, define decision scope and call update proposition API
        
    }
    
    @MainActor
    /// Process region event
    /// - Parameters:
    ///   - regionEvent: region event, such as .entry or .exit
    ///   - region: CLRegion
    func processRegionEvent(regionEvent: PlacesRegionEvent, forRegion region: CLRegion) async {
        // Process geolocation event
       
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
        
    }
    
    
    /// Sample implementation to get access token
    /// - Returns: access token
    func getAccessToken() async -> String {
        let data = NSMutableData(data: "grant_type=client_credentials".data(using: .utf8)!)
        data.append("&client_id=<clientid>".data(using: .utf8)!)
        data.append("&client_secret=<clientsecret>".data(using: .utf8)!)
        data.append("&scope=<scopes>".data(using: .utf8)!)

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
