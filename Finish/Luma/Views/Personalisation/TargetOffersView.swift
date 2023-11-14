//
//  TargetOffersView.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import AEPOptimize
import SwiftUI
import os.log

struct TargetOffersView: View {
    let location: String
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @State private var offersAT = [OfferItem]()
    
    var body: some View {
        Section {
            VStack {
                Spacer()
                if offersAT.count == 0 {
                    Image("aep-logo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .onTapGesture {
                            offersAT.removeAll()
                            Task {
                                await self.updatePropositionsAT(ecid: currentEcid, location: location)
                            }
                        }
                    Spacer()
                }
                else {
                    Spacer()
                    ForEach(offersAT, id: \.content.title) { offerItem in
                        AsyncImage(url: URL(string: offerItem.content.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .center) {
                            Text(offerItem.content.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                            Text(offerItem.content.text)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .lineLimit(10)
                        }
                    }
                }
            }
        } header: {
            Text("Target")
        } footer: {
            Text("\(offersAT.count) offer(s) returned for this location…")
        }
        .onFirstAppear {
            // Invoke callback for offer updates
            Task {
                await self.onPropositionsUpdateAT(location: location)
            }
        }
        .task {
            // Clear and update offers
            await self.updatePropositionsAT(ecid: currentEcid, location: location)
        }
    }
    
    @MainActor
    /// Update AT Propositions
    /// - Parameters:
    ///   - ecid: ecid
    ///   - location: location
    func updatePropositionsAT(ecid: String, location: String) async {
        // clear all offers and call update propositions
        offersAT.removeAll()
        await MobileSDK.shared.updatePropositionsAT(ecid: ecid, location: location)
    }
    
    @MainActor
    /// Get propositions for AT
    /// Would love to have most of this call in MobileSDK, but don't get it to work right now.
    /// Have to look into using @ObservableObject for MobileSDK @Publish for target return values
    /// - Parameter location: target location
    func onPropositionsUpdateAT(location: String) async {
        Task {
            if offersAT.count == 0 {
                let decisionScope = DecisionScope(name: location)
                // Optimize.getPropositions(for: [decisionScope]) { propositionsDict, error in
                Optimize.onPropositionsUpdate { propositionsDict in
                    if let proposition = propositionsDict[decisionScope] {
                        if proposition.offers.count == 0 {
                            Logger.aepMobileSDK.info("TargetOfferView - onPropositionUpdateAT - No AT offers returned…")
                            return
                        }
                        Logger.aepMobileSDK.info("TargetOfferView - onPropositionUpdateAT - Number of AT offers: \(proposition.offers.count)")
                        // the actual offer is piece of content defined in AT
                        if let offer = proposition.offers.first {
                            // get its metadata
                            let contentString = offer.content
                            Logger.aepMobileSDK.info("TargetOfferView - onPropositionUpdateAT - AT content: \(contentString)")
                            if let contentData = contentString.data(using: .utf8) {
                                if let content = try? JSONDecoder().decode(ContentItem.self, from: contentData) {
                                    offersAT.append(OfferItem(offer: offer, content: content))
                                    offer.displayed()
                                }
                            }
                        }
                    }
                    else {
                        Logger.aepMobileSDK.info("TargetOfferView - onPropositionUpdateAT - No proposition…")
                    }
                }
            }
        }
    }
}

struct TargetOffersView_Previews: PreviewProvider {
    static var previews: some View {
        TargetOffersView(location: "")
    }
}
