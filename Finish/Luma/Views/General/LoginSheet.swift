//
//  ConfigSheet.swift
//  Luma
//
//  Created by Rob In der Maur on 23/09/2022.
//

import AEPIdentity
import AEPEdgeIdentity
import AppTrackingTransparency
import SwiftUI

struct LoginSheet: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("currentEmailId") private var currentEmailId = "testUser@gmail.com"
    @AppStorage("currentCRMId") private var currentCRMId = "112ca06ed53d3db37e4cea49cc45b71e"
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("ldap") private var ldap = ""
    @AppStorage("emailDomain") private var emailDomain = "adobetest.com"
    
    @State private var disableLogin = false
    
    var body: some View {
        VStack {
            Form {
                Section {
                    if disableLogin == true {
                        VStack(alignment: .center) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.largeTitle)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(10)
                        }
                        HStack {
                            Text("You are identified with email address ")
                                .font(.footnote)
                            + Text(currentEmailId)
                                .monospaced()
                                .fontWeight(.bold)
                            + Text(".")
                                .font(.footnote)
                        }
                        HStack {
                            Text("You are identified with CRM ID ")
                                .font(.footnote)
                            + Text(currentCRMId)
                                .monospaced()
                                .fontWeight(.bold)
                            + Text(".")
                                .font(.footnote)
                        }
                        HStack {
                            Button("Logout", role: .destructive) {
                                // Remove identities
                                MobileSDK.shared.removeIdentities(emailAddress: currentEmailId, crmId: currentCRMId)
                                
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Done") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            
                        }
                    }
                    else {
                        Image(systemName: "person.fill.questionmark")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(5)
                        TextField("Email", text: $currentEmailId)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .lineLimit(2)
                        TextField("CRM ID", text: $currentCRMId)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .lineLimit(2)
                        HStack {
                            Button {
                                let dateString = Date().formatDate()
                                let randomNumberString = String(format: "%02d", Int.random(in: 1..<100))
                                currentCRMId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
                                currentEmailId = ldap + "+" + dateString + "-" + randomNumberString + "@" + emailDomain
                            } label: {
                                Label {
                                    Text("")
                                } icon: {
                                    Image(systemName: "character.cursor.ibeam")
                                        .font(.footnote)
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Login") {
                                // Update identities
                                MobileSDK.shared.updateIdentities(emailAddress: currentEmailId, crmId: currentCRMId)
                                
                                // Send app interaction event
                                MobileSDK.shared.sendAppInteractionEvent(actionName: "login")
                                
                                dismiss()
                            }
                            .disabled(currentEmailId.isValidEmail == false)
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Identities")
                } footer: {
                    disableLogin ? Text("To use other identities, you have to re-install the app to ensure a new ECID is associated with the new identities…") :  Text("To identify, use new or existing identities you registered with on a website set up with similar configuration through the AEP Web SDK… \nUse \(Image(systemName: "character.cursor.ibeam")) to autocomplete your ldap and emailDomain with a random email identifier (\"\(ldap)+YYYYMMDD-99@\(emailDomain)\") and a random CRM ID…")
                }
                .headerProminence(.increased)
                .padding(.top, 20)
            }
            
        }
        .onAppear {
            Task {
                MobileSDK.shared.getIdentities()
                if currentEmailId == "testUser@gmail.com" || currentEmailId.isValidEmail == false
                {
                    // still allow to log in
                    disableLogin = false
                }
                else {
                    disableLogin = true
                }
            }
            // Send track screen event
            MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: login")
        }
    }
}

struct LoginSheet_Previews: PreviewProvider {
    static var previews: some View {
        LoginSheet()
    }
}
