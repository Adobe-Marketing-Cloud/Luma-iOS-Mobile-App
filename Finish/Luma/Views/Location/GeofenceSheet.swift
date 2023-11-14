//
//  GeofenceSheet.swift
//  Luma
//
//  Created by Rob In der Maur on 24/07/2022.
//

import AEPPlaces
import AppTrackingTransparency
import CoreLocation
import CoreLocationUI
import SwiftUI

struct GeofenceSheet: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    var location: Location
    var region: CLCircularRegion
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Nearby POI")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Image(systemName: "dot.circle.and.hand.point.up.left.fill")
                    .foregroundColor(.accentColor)
            }
            List {
                HStack {
                    Text("Id")
                    Spacer()
                    Text(location.identifier)
                        .fontWeight(.bold)
                        .monospaced()
                }
                HStack {
                    Text("Longitude")
                    Spacer()
                    Text("\(location.longitude)")
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Latitude")
                    Spacer()
                    Text("\(location.latitude)")
                        .fontWeight(.bold)
                }
                HStack(alignment: .top) {
                    Text("Name")
                    Spacer()
                    Text(location.name)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                HStack(alignment: .top) {
                    Text("Street")
                    Spacer()
                    Text(location.street)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("City")
                    Spacer()
                    Text(location.city)
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Country")
                    Spacer()
                    Text("\(location.country) (\(location.countryCode))")
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Category")
                    Spacer()
                    Text(location.category)
                        .fontWeight(.bold)
                }
                HStack(alignment: .top) {
                    Text("Entry Event Id")
                    Spacer()
                    Text(location.entryOrchestrationId)
                        .fontWeight(.bold)
                        .monospaced()
                        .multilineTextAlignment(.trailing)
                }
                HStack(alignment: .top) {
                    Text("Exit Event Id")
                    Spacer()
                    Text(location.entryOrchestrationId)
                        .fontWeight(.bold)
                        .monospaced()
                        .multilineTextAlignment(.trailing)
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .listStyle(.insetGrouped)
            Spacer()
            VStack {
                HStack {
                    Button(action: {
                        // Simulate geofence entry event
                        Task {
                            await MobileSDK.shared.processRegionEvent(regionEvent: .entry, forRegion: region)
                        }
                    }) {
                        Label("Entry", systemImage: "ipad.and.arrow.forward")
                    }
                    .buttonStyle(.bordered)
                    .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized)
                    
                    Spacer()
                    
                    Button(action: {
                        // Simulate geofence exit event
                        Task {
                            await MobileSDK.shared.processRegionEvent(regionEvent: .exit, forRegion: region)
                        }
                    }) {
                        Label("Exit", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .buttonStyle(.bordered)
                    .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized)
                }
            }
        }
        .padding()
    }
}

struct GeofenceSheet_Previews: PreviewProvider {
    static var previews: some View {
        GeofenceSheet(location: Location.example, region: CLCircularRegion())
    }
}
