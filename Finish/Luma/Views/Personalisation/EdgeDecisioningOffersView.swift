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
                                await self.updatePropositionsForSurface()
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
            Text(surfaceName)
        } footer: {
            Text("\(offers.count) offer(s) returned for surface...")
        }
        .task {
            await self.updatePropositionsForSurface()
            try? await Task.sleep(nanoseconds: 500_000_000)
            await self.fetchPropositions()
        }
        .sheet(isPresented: $showInfoSheet) {
            let infoText = """
            SURFACE PARAMETERS
            
            Surface URI: \(surface.uri)
            
            RESPONSE
            
            \(propositionInfo)
            """
            InfoSheet(infoText: .init(infoText))
        }
    }
    
    // MARK: - Methods
    
    @MainActor
    func updatePropositionsForSurface() async {
        Logger.aepMobileSDK.info("DecisioningOffersView - Starting proposition update for surface: \(surface.uri)")
        await MobileSDK.shared.updatePropositionsForSurfaces(surfaces: [surface])
        Logger.aepMobileSDK.info("DecisioningOffersView - updatePropositionsForSurfaces() called")
    }
    
    @MainActor
    func fetchPropositions() async {
        Logger.aepMobileSDK.info("DecisioningOffersView - Fetching propositions for surface: \(surface.uri)")
        
        Messaging.getPropositionsForSurfaces([surface]) { propositionsDict, error in
            if let error = error {
                Logger.aepMobileSDK.error("DecisioningOffersView - Error retrieving propositions: \(error.localizedDescription)")
                return
            }
            
            guard let propositionsDict = propositionsDict else {
                Logger.aepMobileSDK.error("DecisioningOffersView - propositionsDict is nil")
                return
            }
            
            Task { @MainActor in
                Logger.aepMobileSDK.info("DecisioningOffersView - Retrieved \(propositionsDict.count) surface(s)")
                
                var allOffers: [DecisioningOffer] = []
                var infoText = ""
                
                for (responseSurface, propositionsList) in propositionsDict {
                    Logger.aepMobileSDK.info("DecisioningOffersView - Surface: \(responseSurface.uri), Propositions: \(propositionsList.count)")
                    
                    for proposition in propositionsList {
                        infoText += "Proposition ID: \(proposition.uniqueId)\n"
                        infoText += "Scope: \(proposition.scope)\n"
                        infoText += "Items: \(proposition.items.count)\n"
                        
                        for item in proposition.items {
                            if let content = parseCodeBasedContent(from: item.itemData) {
                                if let offers = content.offers {
                                    allOffers.append(contentsOf: offers)
                                    Logger.aepMobileSDK.info("DecisioningOffersView - Parsed \(offers.count) offer(s)")
                                    infoText += "Offers: \(offers.count)\n\n"
                                }
                            }
                        }
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
