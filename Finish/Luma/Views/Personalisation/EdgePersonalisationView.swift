//
//  DecisionPersonalisationView.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import AEPOptimize
import SwiftUI
import os.log

struct EdgePersonalisationView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("targetLocation") private var targetLocation = ""
        
    @State private var decisionScopes =  [Decision]()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(decisionScopes, id: \.activityId) { decision in
                        EdgeOffersView(decision: decision)
                    }
                    TargetOffersView(location: targetLocation)
                }
                .refreshable {
                    await loadDecisions(configLocation: configLocation)
                }
            }
            .task {
                await loadDecisions(configLocation: configLocation)
            }
            .onAppear {
                // Track view screen
                MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: personalisationEdge")
            }
            .navigationTitle("Personalisation")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    @MainActor
    func loadDecisions(configLocation: String) async {
        decisionScopes = await Network.shared.loadDecisions(configLocation: configLocation).decisionScopes
        Logger.configuration.info("EdgePersonalisationView - Loaded \(decisionScopes.count) decisions...")
    }
}

struct EdgePersonalisationView_Previews: PreviewProvider {
    static var previews: some View {
        EdgePersonalisationView()
    }
}
