//
//  LoginView.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import AEPCore
import AEPAssurance
import AEPIdentity
import AEPEdgeIdentity
import AppTrackingTransparency
import SwiftUI
import os.log


struct ConfigView: View {
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("currentEmailId") private var currentEmailId = "testUser@gmail.com"
    @AppStorage("currentDeviceToken") private var currentDeviceToken = ""
    @AppStorage("environmentFileId") private var environmentFileId = "b5cbd1a1220e/1857ef6cacb5/launch-2594f26b23cd-development"
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("currentTestProfile") private var currentTestProfile = false
    @AppStorage("tenant") private var tenant = ""
    @AppStorage("sandbox") private var sandbox = ""
    @AppStorage("testPushEventType") private var testPushEventType = "application.test"
    @AppStorage("brandName") private var brandName = ""
    @AppStorage("brandLogo") private var brandLogo = ""
    @AppStorage("ldap") private var ldap = ""
    @AppStorage("emailDomain") private var emailDomain = "adobetest.com"
    @AppStorage("tms") private var tms = ""
    @AppStorage("accessToken") private var accessToken = ""
    
    @State private var disableLogin = false
    @State private var isExpanded = false
    @State private var showRestartDialog = false
    @State private var showConfigSections = false
    @State private var showTermsOfUseSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                if showConfigSections == true {
                    Section {
                        HStack {
                            TextField("Environment File Id", text: $environmentFileId, onCommit: {
                                showRestartDialog.toggle()
                            })
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.footnote)
                            Spacer()
                            Button("Config") {
                                showRestartDialog.toggle()
                            }
                            .disabled(environmentFileId.isValidEnvironmentFileId == false)
                            .buttonStyle(.bordered)
                            .font(.footnote)
                        }
                    } header: {
                        Text("AEP Data Collection")
                    } footer: {
                        environmentFileId.isValidEnvironmentFileId == false ?
                        Text("Provide a valid environment file id from your AEP Data Collection mobile property")
                            .foregroundColor(.red) :
                        Text("Environment file id for your mobile property in Adobe Experience Platform Data Collection…")
                    }
                    //.headerProminence(.increased)
                    
                    Section {
                        HStack {
                            TextField("Path", text: $configLocation)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .font(.footnote)
                            Spacer()
                            Button("Config") {
                                Task {
                                    await MobileSDK.shared.loadGeneral(configLocation: configLocation)
                                }
                                showRestartDialog.toggle()
                            }
                            .font(.footnote)
                            .buttonStyle(.bordered)
                        }
                        DisclosureGroup(
                            isExpanded: $isExpanded,
                            content: {
                                VStack {
                                    HStack {
                                        Text("Brand:")
                                            .monospaced()
                                        Spacer()
                                        Text(brandName)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack {
                                        Text("LDAP:")
                                            .monospaced()
                                        Spacer()
                                        Text(ldap)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack {
                                        Text("Email Domain:")
                                            .monospaced()
                                        Spacer()
                                        Text(emailDomain)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack {
                                        Text("TMS:")
                                            .monospaced()
                                        Spacer()
                                        Text(tms)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack {
                                        Text("Tenant:")
                                            .monospaced()
                                        Spacer()
                                        Text(tenant)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack {
                                        Text("Sandbox:")
                                            .monospaced()
                                        Spacer()
                                        Text(sandbox)
                                            .monospaced()
                                            .fontWeight(.bold)
                                    }
                                    HStack(alignment: .top) {
                                        Text("Device Token:")
                                            .monospaced()
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(currentDeviceToken)
                                                .monospaced()
                                                .fontWeight(.bold)
                                                .lineLimit(5)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding(0)
                                    }
                                    HStack(alignment: .top) {
                                        Text("Access Token:")
                                            .monospaced()
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(accessToken)
                                                .monospaced()
                                                .fontWeight(.bold)
                                                .lineLimit(100)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding(0)
                                    }
                                    
                                }
                            },
                            label: {
                                tenant.isEmpty || sandbox.isEmpty ?
                                Text("Configuration Details Missing")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .fontWeight(.bold) :
                                Text("Configuration Details")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        )
                        
                    } header: {
                        Text("Configuration Location")
                    } footer: {
                        configLocation == "" ?
                        Text("App is using internal configuration files (general, products, (i)beacons, geofences))")
                            :
                        Text("App is using remote configuration files (general, products, (i)beacons, geofences)…")
                    }
                    //.headerProminence(.increased)
                }
                
                if currentEmailId.isEmpty == false {
                    Section {
                        if showConfigSections == true {
                            Toggle(isOn: $currentTestProfile) {
                                Text("Test Profile")
                                    .font(.footnote)
                            }
                            .onChange(of: currentTestProfile) { value in
                                MobileSDK.shared.sendTrackAction(
                                    action: "updateProfile",
                                    data: ["ecid" : currentEcid, "testProfile" : value])
                            }
                            .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized)
                        }
                        HStack {
                            Button("In-App Message") {
                                // Setting parameters and calling function to send in-app message
                                Task {
                                    MobileSDK.shared.sendTrackAction(action: "in-app", data: ["showMessage": "true"])
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.footnote)
                            Spacer()
                            Button("Push Notification") {
                                // Setting parameters and calling function to send push notification
                                Task {
                                    let eventType = testPushEventType
                                    let applicationId = Bundle.main.bundleIdentifier ?? "No bundle id found"
                                    await MobileSDK.shared.sendTestPushEvent(applicationId: applicationId, eventType: eventType)
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.footnote)
                        }
                    } header: {
                        Text("Test")
                    } footer: {
                        Text("Toggle Test Profile on to allow to test with this profile in Adobe Journey Optimizer.")
                    }
                }
                
                Section {
                    HStack {
                        Text("Terms of Use")
                            .font(.footnote)
                        Spacer()
                        Button("View...") {
                            showTermsOfUseSheet.toggle()
                        }
                        .buttonStyle(.bordered)
                        .font(.footnote)
                    }
                    HStack {
                        ATTrackingManager.trackingAuthorizationStatus == .authorized ? Text("Tracking is allowed…").font(.footnote) : Text("Tracking is NOT allowed…").font(.footnote).foregroundColor(.red).fontWeight(.bold)
                        Spacer()
                        Link("App Settings…", destination: URL(string: UIApplication.openSettingsURLString)!)
                            .buttonStyle(.bordered)
                            .font(.footnote)
                    }
                } header: {
                    Text("Application")
                } footer: {
                    Text("Open App Settings for Luma to set tracking preference…")
                }
            }
            .onTapGesture(count: 4, perform: {
                showConfigSections.toggle()
            })
            .sheet(isPresented: $showTermsOfUseSheet) {
                TermsOfUseSheet()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            environmentFileId = "2a518741ab24/ec01f7dc7ed6/launch-384206a7fc37-development"
                            configLocation = ""
                            Task {
                                await MobileSDK.shared.loadGeneral(configLocation: configLocation)
                            }
                            showRestartDialog.toggle()
                        } label: {
                            Image(systemName: "testtube.2")
                        }
                        .disabled(environmentFileId.isEmpty == false || configLocation.isEmpty == false)
                    }
                }
            }
            .alert(isPresented:$showRestartDialog) {
                Alert(
                    title: Text("App Needs Restart!"),
                    message: Text("Restart the app to pick up the new configuration…"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                showConfigSections = false
                // Track view screen
                MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: config")
            }
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}
