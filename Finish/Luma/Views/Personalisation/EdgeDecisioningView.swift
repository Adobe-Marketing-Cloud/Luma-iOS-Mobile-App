//
//  EdgeDecisioningView.swift
//  Luma
//
//
//  Created by Rob In der Maur on 9/7/2026.
//

import AEPMessaging
import SwiftUI
import os.log

struct EdgeDecisioningView: View {
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("decisioningSurface") private var decisioningSurface = ""
    @AppStorage("targetLocation") private var targetLocation = ""
    
    // Define your surfaces here
    // Add more surfaces as needed for different decisioning placements
    private var surfaces: [(surface: Surface, name: String)] {
        [
            //(Surface(path: "offersLocation"), "Offers Location")
            (Surface(path: decisioningSurface), "Offers Location")
            // Add more surfaces here as needed:
            // (Surface(path: "homepage"), "Homepage Offers"),
            // (Surface(path: "checkout"), "Checkout Offers")
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(surfaces, id: \.surface.uri) { surfaceInfo in
                        EdgeDecisioningOffersView(
                            surface: surfaceInfo.surface,
                            surfaceName: surfaceInfo.name
                        )
                    }
                }
                .refreshable {
                    // Pull to refresh will trigger the .task in each DecisioningOffersView
                    Logger.aepMobileSDK.info("EdgeDecisioningView - Refresh triggered")
                }
            }
            .onAppear {
                Logger.aepMobileSDK.info("EdgeDecisioningView - onAppear")
                Logger.aepMobileSDK.info("EdgeDecisioningView - decisioningSurface from AppStorage: '\(decisioningSurface)'")
                Logger.aepMobileSDK.info("EdgeDecisioningView - Number of surfaces: \(surfaces.count)")
                if let firstSurface = surfaces.first {
                    Logger.aepMobileSDK.info("EdgeDecisioningView - First surface URI: '\(firstSurface.surface.uri)'")
                }
                MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: edgeDecisioning")
            }
            .navigationTitle("Personalisation")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

struct EdgeDecisioningView_Previews: PreviewProvider {
    static var previews: some View {
        EdgeDecisioningView()
    }
}

