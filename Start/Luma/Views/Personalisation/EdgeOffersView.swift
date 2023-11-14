//
//  OfferItemView.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import AEPOptimize
import SwiftUI
import os.log

struct EdgeOffersView: View {
    let decision: Decision
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @State private var offersOD = [OfferItem]()
    @State private var showInfoSheet = false
    
    var body: some View {
        Section {
            VStack {
                if offersOD.count == 0 {
                    Spacer()
                    Image("aep-logo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .onTapGesture {
                            offersOD.removeAll()
                            Task {
                                await self.updatePropositionsOD(ecid: currentEcid, activityId: decision.activityId, placementId: decision.placementId, itemCount: decision.itemCount)
                            }
                        }
                    Spacer()
                }
                else {
                    ForEach(offersOD, id: \.content.title) { offerItem in
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
            Text("Decision \(decision.name ?? "")")
        } footer: {
            Text("\(offersOD.count) offer(s) returned for this decision…")
        }
        .onFirstAppear {
            // Invoke callback for offer updates
            
        }
        .task {
            // Clear and update offers
            
        }
        .sheet(isPresented: $showInfoSheet) {
            let infoText =  """
            PARAMETERS FOR DECISION\n
            activityId: \(decision.activityId)\n
            placementId: \(decision.placementId)\n
            itemCount: \(decision.itemCount)
            \n\n
            RESPONSE (offer objects)\n
            \(offersOD)
            """
            InfoSheet(infoText: .init(infoText))
        }
    }
    
    @MainActor
    /// Update OD Propositions
    /// - Parameters:
    ///   - ecid: ecid
    ///   - activityId: activityId
    ///   - placementId: placementId
    ///   - itemCount: number of offers to return
    func updatePropositionsOD(ecid: String, activityId: String, placementId: String, itemCount: Int) async {
        offersOD.removeAll()
        await MobileSDK.shared.updatePropositionsOD(
            ecid: ecid,
            activityId: activityId,
            placementId: placementId,
            itemCount: itemCount
        )
    }
    
    @MainActor
    /// Get propositions for OD
    /// Would love to have most of this call in MobileSDK, but don't get it to work right now.
    /// Have to look into using @ObservableObject for MobileSDK @Publish for offers
    /// - Parameters:
    ///   - activityId: activityId
    ///   - placementId: placementId
    ///   - itemCount: itemCound
    func onPropositionsUpdateOD(activityId: String, placementId: String, itemCount: Int) async {
        // Get propositions and retrieve content to use in the app
        Task {
            if offersOD.count == 0 {
                let decisionScope = DecisionScope(activityId: activityId, placementId: placementId, itemCount: UInt(itemCount))
                Optimize.onPropositionsUpdate { propositionsDict in
                    if let proposition = propositionsDict[decisionScope] {
                        Logger.aepMobileSDK.info("EdgeOffersView - getPropositionOD - Number of OD offers: \(proposition.offers.count)")
                        if proposition.offers.count > 0 {
                            for offer in proposition.offers {
                                // get its metadata
                                let contentString = offer.content
                                Logger.aepMobileSDK.info("EdgeOffersView - getPropositionOD - OD content: \(contentString)")
                                if let contentData = contentString.data(using: .utf8) {
                                    if let content = try? JSONDecoder().decode(ContentItem.self, from: contentData) {
                                        offersOD.append(OfferItem(offer: offer, content: content))
                                        offer.displayed()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EdgeOffersView_Previews: PreviewProvider {
    static var previews: some View {
        EdgeOffersView(decision: Decision(name: "", activityId: "", placementId: "", itemCount: 0))
    }
}
