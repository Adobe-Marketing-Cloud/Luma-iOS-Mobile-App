//
//  DecisioningOffersView.swift
//  Luma
//
//
//  Created by Rob In der Maur on 9/7/2026.
//

import AEPMessaging
import SwiftUI
import os.log

struct EdgeDecisioningOffersView: View {
    let surface: Surface
    let surfaceName: String
    
    @State private var offers = [DecisioningOffer]()
    @State private var showInfoSheet = false
    @State private var propositionInfo: String = ""
    @State private var errorInfo: String = ""
    @State private var lastFetchTime: Date?
    
    var body: some View {
        Section {
            VStack {
                if offers.isEmpty {
                    Spacer()
                    Image("aep-logo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .onTapGesture {
                            offers.removeAll()
                            Task {
                                self.updatePropositionsForSurface()
                            }
                        }
                    Spacer()
                } else {
                    ForEach(offers) { offer in
                        if let imageStr = offer.image, let imageUrl = URL(string: imageStr) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        VStack(alignment: .center) {
                            if let title = offer.title {
                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                            }
                            
                            if let text = offer.text {
                                Text(text)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(10)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button {
                            showInfoSheet.toggle()
                        } label: {
                            Label("", systemImage: "info.circle.fill")
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
            }
        } header: {
            Text("Surface \(surfaceName)")
        } footer: {
            Text("\(offers.count) offer(s) returned for surface...")
        }
        .task {
            Logger.aepMobileSDK.info("DecisioningOffersView - Task started")

            // Step 1: Update propositions (triggers network request to Edge Network)
            self.updatePropositionsForSurface()
            Logger.aepMobileSDK.info("DecisioningOffersView - Called updatePropositionsForSurface()")
            
            // Step 2: Brief wait for Edge Network to respond and cache propositions
            Logger.aepMobileSDK.info("DecisioningOffersView - Waiting 0.5 seconds for Edge Network response...")
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Step 3: Fetch the cached propositions
            Logger.aepMobileSDK.info("DecisioningOffersView - Now fetching cached propositions")
            await self.fetchPropositions()
            
            Logger.aepMobileSDK.info("DecisioningOffersView - Task completed with \(offers.count) offer(s)")
        }
        .sheet(isPresented: $showInfoSheet) {
            let timestamp = lastFetchTime?.formatted() ?? "Never"
            let infoText = """
            SURFACE PARAMETERS
            Surface URI: \(surface.uri)
            Last Fetch: \(timestamp)
            
            PROPOSITIONS RESPONSE
            \(propositionInfo.isEmpty ? "No propositions received" : propositionInfo)
            
            """
            
            InfoSheet(infoText: .init(infoText))
        }
    }
    
    // MARK: - Methods
    
    func updatePropositionsForSurface() {
        Logger.aepMobileSDK.info("DecisioningOffersView - Starting proposition update for surface: \(surface.uri)")
        
        // Call MobileSDK updatePropositionsForSurfaces Wrapper API to update propositions (this will fetch fresh from Edge network)
        MobileSDK.shared.updatePropositionsForSurfaces(surfaces: [surface])
        
        Logger.aepMobileSDK.info("DecisioningOffersView - updatePropositionsForSurfaces() called directly on Messaging")
    }
    
    @MainActor
    func fetchPropositions() async {
        Logger.aepMobileSDK.info("DecisioningOffersView - Fetching propositions for surface: \(surface.uri)")
        self.lastFetchTime = Date()
        
        Messaging.getPropositionsForSurfaces([surface]) { propositionsDict, error in
            Task { @MainActor in
                if let error = error {
                    let errorMsg = "Error: \(error.localizedDescription)\n\(String(describing: error))"
                    Logger.aepMobileSDK.error("DecisioningOffersView - Error: \(error.localizedDescription)")
                    self.errorInfo = errorMsg
                    return
                }
                
                guard let propositionsDict = propositionsDict else {
                    Logger.aepMobileSDK.error("DecisioningOffersView - propositionsDict is nil")
                    self.errorInfo = """
                    No data returned from cache.
                    
                    CRITICAL: getPropositionsForSurfaces only returns CACHED propositions.
                    The surface must be cached BEFORE calling this API.
                    
                    If you see this error:
                    1. Check console for Edge Network errors (422, policy ID errors)
                    2. Surface may not have been cached yet (try pull-to-refresh)
                    3. Edge Network may have returned an error (check decisioning policy ID)
                    """
                    return
                }
                
                Logger.aepMobileSDK.info("DecisioningOffersView - Retrieved \(propositionsDict.count) surface(s)")
                
                var allOffers: [DecisioningOffer] = []
                var infoText = ""
                
                if propositionsDict.isEmpty {
                    self.errorInfo = """
                    Empty propositions dictionary returned.
                    
                    This means the SDK has no cached propositions for this surface.
                    
                    Possible causes:
                    1. Edge Network returned an error (check console for 422 errors)
                    2. Campaign is not Live in AJO
                    3. Surface URI mismatch between app and AJO campaign
                    4. Decision policy ID error (old cached policy on Edge Network)
                    5. Network request still in progress (try pull-to-refresh)
                    """
                }
                
                for (responseSurface, propositionsList) in propositionsDict {
                    Logger.aepMobileSDK.info("DecisioningOffersView - Surface: \(responseSurface.uri), Propositions: \(propositionsList.count)")
                    
                    for proposition in propositionsList {
                        infoText += "Proposition ID: \(proposition.uniqueId)\n"
                        infoText += "Scope: \(proposition.scope)\n"
                        infoText += "Items: \(proposition.items.count)\n"
                        
                        Logger.aepMobileSDK.info("DecisioningOffersView - Proposition details: ID=\(proposition.uniqueId), Scope=\(proposition.scope)")
                        
                        for item in proposition.items {
                            // Log item ID which may contain policy information
                            Logger.aepMobileSDK.info("DecisioningOffersView - Item ID: \(item.itemId)")
                            infoText += "Item ID: \(item.itemId)\n"
                            
                            if let content = parseCodeBasedContent(from: item.itemData) {
                                if let offers = content.offers {
                                    allOffers.append(contentsOf: offers)
                                    Logger.aepMobileSDK.info("DecisioningOffersView - Parsed \(offers.count) offer(s)")
                                    infoText += "Offers: \(offers.count)\n\n"
                                }
                            }
                        }
                        
                        infoText += "\n"
                    }
                }
                
                self.offers = allOffers
                self.propositionInfo = infoText
                Logger.aepMobileSDK.info("DecisioningOffersView - Total offers to display: \(allOffers.count)")
            }
        }
    }
    
    // MARK: - Content Parsing
    
    func parseCodeBasedContent(from itemData: [String: Any]) -> CodeBasedContent? {
        guard let content = itemData["content"] as? [String: Any] else {
            Logger.aepMobileSDK.error("DecisioningOffersView - No 'content' key found in itemData")
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: content, options: [])
            let decoder = JSONDecoder()
            let codeBasedContent = try decoder.decode(CodeBasedContent.self, from: jsonData)
            Logger.aepMobileSDK.info("DecisioningOffersView - Successfully parsed content")
            return codeBasedContent
        } catch {
            Logger.aepMobileSDK.error("DecisioningOffersView - Failed to parse content: \(error.localizedDescription)")
            return nil
        }
    }
}

struct DecisioningOffersView_Previews: PreviewProvider {
    static var previews: some View {
        EdgeDecisioningOffersView(surface: Surface(path: "test"), surfaceName: "Test Surface")
    }
}
