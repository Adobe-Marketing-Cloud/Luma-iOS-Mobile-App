//
//  ContentView.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import AEPEdgeConsent
import AEPIdentity
import AEPEdgeIdentity
import AppTrackingTransparency
import SwiftUI

struct ContentView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("currentEmailId") private var currentEmailId = "testUser@gmail.com"
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("environmentFileId") private var environmentFileId = "b5cbd1a1220e/1857ef6cacb5/launch-2594f26b23cd-development"
    @AppStorage("productsType") private var productsType = "Products"
    @AppStorage("productsSystemImage") private var productsSystemImage = "cart"
    @AppStorage("showProducts") private var showProducts: Bool = true
    @AppStorage("showPersonalisation") private var showPersonalisation:Bool = true
    @AppStorage("showPersonalisationDirect") private var showPersonalisationDirect: Bool = true
    @AppStorage("showGeofences") private var showGeofences: Bool = true
    @AppStorage("showBeacons") private var showBeacons: Bool = true
    
    @State var general: General?
    @State private var selection: String? = nil
    
    @State private var showConsentAlert = false
    @State private var showConfigAlert = false
    
    var body: some View {
        if ATTrackingManager.trackingAuthorizationStatus != .authorized {
            DisclaimerView()
        }
        else {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag("Home")
                
                if showProducts == true {
                    ProductsView()
                        .tabItem {
                            Image(systemName: productsSystemImage)
                            Text(productsType)
                        }
                        .tag("Products")
                }
                
                
                if showPersonalisation == true && showPersonalisationDirect == false {
                    EdgePersonalisationView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Personalisation")
                        }
                        .tag("Personalisation")
                }
                if showPersonalisation == true && showPersonalisationDirect == true {
                    PersonalisationView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Personalisation")
                        }
                        .tag("Personalisation")
                }
                
                if showBeacons == true && showGeofences == true {
                    LocationView()
                        .tabItem {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Location")
                        }
                        .tag("Location")
                        .edgesIgnoringSafeArea(.top)
                }
                if showBeacons == false && showGeofences == true {
                    GeofencesView()
                        .tabItem {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Location")
                        }
                        .tag("Location")
                        .edgesIgnoringSafeArea(.top)
                }
                if showBeacons == true && showGeofences == false {
                    LocationView()
                        .tabItem {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Location")
                        }
                        .tag("Location")
                        .edgesIgnoringSafeArea(.top)
                }
                ConfigView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag("Settings")
            }
            .tabViewStyle(.automatic)
            .alert(isPresented:$showConfigAlert) {
                Alert(
                    title: Text("App Needs Configuration!"),
                    message: Text("Go to Config to configure the app…"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                MobileSDK.shared.getIdentities()
            }
            .task {
                await MobileSDK.shared.loadGeneral(configLocation: configLocation)
            }
            .task {
                // Load general configuration
                await MobileSDK.shared.loadGeneral(configLocation: configLocation)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
