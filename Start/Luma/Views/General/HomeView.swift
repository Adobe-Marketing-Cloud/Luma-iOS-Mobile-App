//
//  HomeView.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import AEPIdentity
import AEPEdgeIdentity
import AEPEdgeConsent
import AEPUserProfile
import AppTrackingTransparency
import SwiftUI
import os.log

struct HomeView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("currentEmailId") private var currentEmailId = "testUser@gmail.com"
    @AppStorage("currentCRMId") private var currentCRMId = "112ca06ed53d3db37e4cea49cc45b71e"
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("environmentFileId") private var environmentFileId = "b5cbd1a1220e/1857ef6cacb5/launch-2594f26b23cd-development"
    @AppStorage("brandName") private var brandName = "Luma"
    @AppStorage("brandLogo") private var brandLogo = "https://contentviewer.s3.amazonaws.com/helium/luma-logo01.png"
    
    @State private var showLoginSheet = false
    @State private var showBadgeForUser = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
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
                        Text("Welcome to the...")
                            .font(.footnote)
                        Text(brandName)
                            .fontWeight(.bold)
                        Text("iOS Sample App!\n")
                            .font(.footnote)
                        Text("Showing how to use the")
                            .font(.footnote)
                        Text("Adobe Experience Platform Mobile SDK…")
                            .font(.footnote)
                    }
                    .padding()
                }
                
                Section {
                    HStack(alignment: .center) {
                        Text("ECID:")
                        Spacer()
                        currentEcid.isEmpty ?
                        Text("not available")
                            .monospaced()
                            .fontWeight(.bold)
                            // .foregroundColor(.red)
                            .onTapGesture {
                                // UIPasteboard.general.setValue(currentEcid, forPasteboardType: "public.plain-text")
                            }
                        :
                        Text(currentEcid)
                            .monospaced()
                            .fontWeight(.bold)
                            .onTapGesture {
                                UIPasteboard.general.setValue(currentEcid, forPasteboardType: "public.plain-text")
                            }
                    }
                    
                    HStack(alignment: .center) {
                        Text("Email:")
                        Spacer()
                        Text(currentEmailId)
                            .monospaced()
                            .fontWeight(.bold)
                            .onTapGesture {
                                UIPasteboard.general.setValue(currentEmailId, forPasteboardType: "public.plain-text")
                            }
                    }
                    HStack(alignment: .center) {
                        Text("CRM ID:")
                        Spacer()
                        Text(currentCRMId)
                            .monospaced()
                            .fontWeight(.bold)
                            .onTapGesture {
                                UIPasteboard.general.setValue(currentEmailId, forPasteboardType: "public.plain-text")
                            }
                    }
                } header: {
                    Text("Identities")
                } footer: {
                    currentEmailId == "testUser@gmail.com" ?
                    Text("If tracking is allowed, use the Person button to login using a new or existing email address…") :
                    Text("Reinstall the app to login using a different email address…")
                }
                .headerProminence(.increased)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showLoginSheet.toggle()
                        } label: {
                            if showBadgeForUser == true {
                                Image(systemName: "person.badge.shield.checkmark")
                            }
                            else {
                                Image(systemName: "person")
                            }
                        }
                        .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized || currentEcid.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginSheet()
                    .interactiveDismissDisabled()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.automatic)
        }
        
        .task {
            // Ask status of consents
            
        }
        .onAppear {
            // Track view screen
            
            // Get attributes

            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
