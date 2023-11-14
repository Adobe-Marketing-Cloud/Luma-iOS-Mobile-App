//
//  DisclaimerView.swift
//  Luma
//
//  Created by Rob In der Maur on 29/07/2022.
//

import AppTrackingTransparency
import AEPEdgeConsent
import AEPCore
import SwiftUI
import os.log

struct DisclaimerView: View {
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("brandName") private var brandName = "Luma"
    @AppStorage("brandLogo") private var brandLogo = "https://contentviewer.s3.amazonaws.com/helium/luma-logo01.png"
    
    var body: some View {
        VStack(alignment: .center) {
            AsyncImage(
                url: URL(string: brandLogo),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                    // .frame(maxWidth: 300, maxHeight: 100)
                },
                placeholder: {
                    Image("luma-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            )
            Text("Welcome to the **\(brandName)** iOS Sample App,\nshowing how to use the Adobe Experience Platform Mobile SDK…")
                .lineLimit(3)
                .multilineTextAlignment(.center)
            Spacer()
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                Text("This app is to illustrate how to use the Adobe Experience Platform Mobile SDK in an iOS Swift(UI) application. In compliance with Apple\'s Tracking Transparency, tap **Continue…** to be prompted to allow the app to track your activity. Select **Allow** for the app to allow tracking and collect events which will enable personalization (offers, push notification messages) in the app. Select **Ask App Not to Track** if you do not want the app to track your activity and collectt events; you will not receive personalized offers and/or messages.")
                    .multilineTextAlignment(.center)
                
                Button("Continue…") {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        // Add consent based on authorization
                        if status == .authorized {
                            // Set consent to yes
                            MobileSDK.shared.updateConsent(value: "y")
                        }
                        else {
                            // set consent to no
                            MobileSDK.shared.updateConsent(value: "n")
                        }
                        Logger.aepMobileSDK.info("Luma - ATTrackingManager status: \(status.self.rawValue)")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .task {
            await MobileSDK.shared.loadGeneral(configLocation: configLocation)
        }
        .onAppear {
            // Track view screen
            MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: disclaimer")
        }
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerView()
    }
}
