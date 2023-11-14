//
//  Connectivity.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//

import SwiftUI

struct LocationView: View {
    @State private var simulation = true
    @StateObject var locationManager = LocationManager()
    @AppStorage("showGeofences") private var showGeofences:Bool = true
    @AppStorage("showBeacons") private var showBeacons:Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                if showGeofences == true {
                    Section {
                        NavigationLink(destination: GeofencesView()) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("Use and/or Simulate Geofences")
                            }
                        }
                    } header: {
                        Text("Geofences")
                    }
                    .headerProminence(.increased)
                }
                
                if showBeacons == true {
                    Section {
                        NavigationLink(destination: BeaconsView()) {
                            HStack {
                                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                Text("Use and/or Simulate Beacons")
                            }
                        }
                    } header: {
                        Text("Beacons")
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.automatic)
            
        }
        .onAppear {
            // Track view screen
            
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
