//
//  BeaconsView.swift
//  Luma
//
//  Created by Rob In der Maur on 01/06/2022.
//

import AppTrackingTransparency
import SwiftUI
import os.log

struct SelectionCell: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    let beaconTitle: String
    @Binding var selectedBeaconTitle: String?
    let beaconUUID: String
    let beaconMajor: Double
    let beaconMinor: Double
    let beaconIdentifier: String
    let beaconLocation: String
    let beaconCategory: String
    let beaconStatus: String
    let beaconSymbol: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(beaconTitle)
                        .fontWeight(.bold)
                }
                Spacer()
                HStack {
                    VStack(alignment: .trailing) {
                        Text(beaconStatus)
                            .monospaced()
                            .fontWeight(.bold)
                    }
                    Image(systemName: beaconSymbol)
                        .foregroundColor(.accentColor)
                }
            }

            VStack(alignment: .leading) {
                Text("\(beaconUUID)|\(String(beaconMajor))|\(String(beaconMinor))")
                    .monospaced()
                Text("\(beaconIdentifier)|\(beaconCategory)")
                    .monospaced()
                Text("\(beaconLocation)")
                    .monospaced()
                
            }
            .foregroundColor(.secondary)
            
            if self.selectedBeaconTitle == self.beaconTitle /*&& self.beaconStatus == "unknown" */ {
                HStack {
                    Button(action: {
                        Task {
                            await MobileSDK.shared.sendBeaconEvent(ecid: currentEcid, eventType: "location.entry", name: beaconTitle, id: beaconIdentifier, category: beaconCategory, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
                        }
                    }) {
                        Label("Entry", systemImage: "ipad.and.arrow.forward")
                            .font(.footnote)
                    }
                    .buttonStyle(.bordered)
                    .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized)
                    Spacer()
                    Button(action: {
                        Task {
                            await MobileSDK.shared.sendBeaconEvent(ecid: currentEcid, eventType: "location.exit", name: beaconTitle, id: beaconIdentifier, category: beaconCategory, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
                        }
                    }) {
                        Label("Exit", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.footnote)
                    }
                    .buttonStyle(.bordered)
                    .disabled(ATTrackingManager.trackingAuthorizationStatus != .authorized)
                }
            }
        }
        .onTapGesture {
            self.selectedBeaconTitle = self.beaconTitle
        }
        .onChange(of: beaconStatus) { [beaconStatus] newValue in
            if beaconStatus != newValue && newValue == "immediate" {
                Logger.notifications.info("BeaconsView - Beacon: \(self.beaconTitle) within immediate reach…")
                Task {
                    await MobileSDK.shared.sendBeaconEvent(ecid: currentEcid, eventType: "location.entry", name: beaconTitle, id: beaconIdentifier, category: beaconCategory, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
                }
                
            }
            if beaconStatus != newValue && beaconStatus == "immediate" {
                Logger.notifications.info("BeaconsView - Beacon: \(self.beaconTitle) outside immediate reach…")
                Task {
                    await MobileSDK.shared.sendBeaconEvent(ecid: currentEcid, eventType: "location.exit", name: beaconTitle, id: beaconIdentifier, category: beaconCategory, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
                }
            }
        }
    }
}

struct BeaconsView: View {
    @AppStorage("currentEcid") private var currentEcid = ""
    @AppStorage("configLocation") private var configLocation = ""
    @State var selectedBeaconTitle: String? = nil
    @State var simulationMode = false
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        Form {
            Section {
                List(locationManager.ibeacons.sorted(by: { $0.title < $1.title }), id: \.major, selection: $selectedBeaconTitle) { beacon in
                    withAnimation {
                        SelectionCell(
                            beaconTitle: beacon.title,
                            selectedBeaconTitle: $selectedBeaconTitle,
                            beaconUUID: beacon.uuid,
                            beaconMajor: beacon.major,
                            beaconMinor: beacon.minor,
                            beaconIdentifier: beacon.identifier,
                            beaconLocation: beacon.location,
                            beaconCategory: beacon.category ?? "",
                            beaconStatus: beacon.status,
                            beaconSymbol: beacon.symbol
                        )
                    }
                }
            } header: {
                Text("Beacons")
            } footer: {
                Text("Shows a list of configured beacons and their statuses. To simulate, select a beacon and choose Entry or Exit")
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Beacons")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            locationManager.ibeacons = await Network.shared.loadIBeacons(configLocation: configLocation)
            for ibeacon in locationManager.ibeacons {
                Logger.configuration.info("Defined IBeacon: \(ibeacon.title)")
            }
            Logger.viewCycle.info("BeaconsView - locationManager: we loaded \(locationManager.ibeacons.count) beacons…")
            try? await Task.sleep(seconds: 2)
            Task {
                locationManager.startScanning()
            }
        }
        .onAppear {
            // Track view screen
            
        }
    }
}

struct BeaconsView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconsView()
    }
}
