//
//  PersonalisationView.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import SwiftUI

struct PersonalisationView: View {
    @AppStorage("showPersonalisationDirect") private var showPersonalisationDirect: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: EdgePersonalisationView()) {
                        HStack {
                            Image(systemName: "scope")
                            Text("Edge Personalisation")
                        }
                    }
                } header: {
                    Text("Edge")
                } footer: {
                    Text("Apply personalisation for profile using Edge Network and the Journey Optimizer - Decisioning extension of the AEP Mobile SDK.")
                }
                .headerProminence(.increased)
                
                if showPersonalisationDirect == true {
                    Section {
                        NavigationLink(destination: DirectPersonalisationView()) {
                            HStack {
                                Image(systemName: "target")
                                Text("Direct Personalisation")
                            }
                        }
                    } header: {
                        Text("Direct")
                    } footer: {
                        Text("Apply personalisation for profile using Decision Managemenent API.")
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Personalisation")
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onAppear {
            // Track view screen
            
        }
    }
        
}

struct PersonalisationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalisationView()
    }
}
