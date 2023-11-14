//
//  DirectPersonalisationView.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import SwiftUI
import os.log

struct DirectPersonalisationView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("targetLocation") private var targetLocation = ""
    @AppStorage("sandbox") private var sandbox = ""
    @AppStorage("accessToken") private var accessToken = ""
    
    @State private var decisions: Decisions = Decisions.example
    @State private var propositions = [Proposition]()
    @State private var showInfoSheet = false
    @State private var showAccessTokenConfirmation = false
    
    var body: some View {
        VStack {
            Form {
                if propositions.count == 0 {
                    Section {
                        Text("No propositions found…")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("If this is unexpected, ensure your offer decisions configuration is correct or your access token is valid. To refresh your access token, use \(Image(systemName: "key.fill")) and swipe down to refresh offers…")
                            .font(.footnote)
                    } footer: {
                        Text("Pull down to refresh…")
                    }

                    
                }
                else {
                    ForEach(propositions.indices, id: \.self) { idx in
                        DirectOffersView(proposition: propositions[idx], index: idx)
                    }
                }
            }
            .refreshable {
                await self.getPropostionsFromDecisions(configLocation: configLocation)
            }
        }
        .task() {
            await self.getPropostionsFromDecisions(configLocation: configLocation)
        }
        .onAppear {
            // Track view screen
            MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: personalisationDirect")
        }
        .navigationTitle("Direct")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showInfoSheet.toggle()
                } label: {
                    Label("Info", systemImage: "info.circle.fill")
                        .font(.footnote)
                }
                Button {
                    Task {
                        accessToken = await MobileSDK.shared.getAccessToken()
                        showAccessTokenConfirmation.toggle()
                    }
                } label: {
                    Label("Access Token", systemImage: "key.fill")
                        .font(.footnote)
                }
            }
        }
        .alert(isPresented: $showAccessTokenConfirmation, content: {
            Alert(
                title: Text( "OAuth access token…"),
                message: accessToken.isEmpty ? Text("Failed to refresh OAuth access token! Check your configuration…" ) : Text("OAuth access token is refreshed…"))
        })
        .sheet(isPresented: $showInfoSheet) {
            let infoText =  """
            REQUEST PARAMETERS\n
            apiKey: \(decisions.apiKey)\n
            clientSecret: \(decisions.clientSecret)\n
            scopes: \(decisions.scopes)\n
            orgId: \(decisions.orgId)\n
            containerId: \(decisions.containerId)\n
            allowDuplicateAcrossActivities: \(decisions.allowDuplicatesAcrossActivities)\n
            allowDuplicateAcrossPlacements: \(decisions.allowDuplicatesAcrossPlacements)\n
            dryRun: \(decisions.dryRun)\n
            decisionScopes: \(decisions.decisionScopes)\n
            sandbox: \(sandbox)\n
            \n\n
            RESPONSE [proposition objects]\n
            \(propositions)
            """
            InfoSheet(infoText: .init(infoText))
        }
    }
    
    func getPropostionsFromDecisions(configLocation: String) async {
        decisions = await Network.shared.loadDecisions(configLocation: configLocation)
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: containerId: \(decisions.containerId)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: accessToken: \(accessToken)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: apiKey: \(decisions.apiKey)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: orgId: \(decisions.orgId)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: allowDuplicatesAcrossActivities: \(decisions.allowDuplicatesAcrossActivities)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: allowDuplicatesAcrossPlacements: \(decisions.allowDuplicatesAcrossPlacements)")
        Logger.configuration.info("DirectPersonalisationView - getPropostionsFromDecisions: dryRun: \(decisions.dryRun)")
        
        // do the call
        propositions = [Proposition]()
        await propositions = MobileSDK.shared.requestDirectOffers(
            ecid: currentEcid,
            containerId: decisions.containerId,
            accessToken: accessToken,
            apiKey: decisions.apiKey,
            orgId: decisions.orgId,
            allowDuplicatesAcrossActivities: decisions.allowDuplicatesAcrossActivities,
            allowDuplicatesAcrossPlacements: decisions.allowDuplicatesAcrossPlacements,
            dryRun: decisions.dryRun,
            decisionScopes: decisions.decisionScopes
        )
        
        Logger.aepDirectAPI.info("DirectPersonalisationView - getPropostionsFromDecisions returns \(propositions.count) propositions…")
        
    }
}

struct DirectPersonalisationView_Previews: PreviewProvider {
    static var previews: some View {
        DirectPersonalisationView()
    }
}
