//
//  GeofenceView.swift
//  Luma
//
//  Created by Rob In der Maur on 01/06/2022.
//


import AEPPlaces
import CoreLocation
import CoreLocationUI
import MapKit
import SwiftUI
import os.log

struct GeofencesView: View {
    @AppStorage("configLocation") private var configLocation = ""
    @AppStorage("longitude") var longitude = 4.8919
    @AppStorage("latitude") var latitude = 52.37109
    @AppStorage("zoom") var zoom = 2.0
    @StateObject var viewModel = ViewModel()
    // @State var locations = [Location]()
    @StateObject var locationManager = LocationManager()
    @State private var showGeofenceSheet = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.mapRegion, interactionModes: MapInteractionModes.all, showsUserLocation: true, userTrackingMode: .constant(.none), annotationItems: viewModel.locations) { location in
                // Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(.white)
                            .clipShape(Circle())
                        
                        Text(location.name)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(5)
                            .background(.gray)
                    }
                    .onTapGesture {
                        Logger.viewCycle.info("GeofencesView - onTapGesture: Geofences found: \(viewModel.locations.count)")
                        if viewModel.locations.count == 1 {
                            showGeofenceSheet.toggle()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea([.top, .trailing, .leading])
            
            Circle()
                .fill(.blue)
                .opacity(0.8)
                .frame(width: 32, height: 32)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        Task {
                            await viewModel.setLocation(configLocation: configLocation)
                            if let region = viewModel.region {
                                // start monitoring the region with the POI in it
                                region.notifyOnEntry = true
                                region.notifyOnExit = true
                                locationManager.manager.startMonitoring(for: region)
                            }
                        }
                    } label: {
                        Image(systemName: "dot.circle.and.hand.point.up.left.fill")
                            .padding()
                            .background(.blue.opacity(0.75))
                            .foregroundColor(.white)
                        //.font(.title)
                            .clipShape(Circle())
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showGeofenceSheet) {
            GeofenceSheet(location: viewModel.locations.first ?? Location.example, region: viewModel.region ?? CLCircularRegion())
        }
        .onAppear {
            Logger.viewCycle.info("GeofencesView - onApper: Initial Location latitude: \(latitude)")
            Logger.viewCycle.info("GeofencesView - onApper: Initial Location longitude \(longitude)")
            Logger.viewCycle.info("GeofencesView - onApper: Initial Zoom: \(zoom)")
            viewModel.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: zoom < 180 ? zoom : 10, longitudeDelta: zoom < 180 ? zoom : 180))
            // Track view screen
            
        }
    }
}

struct GeofencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeofencesView()
    }
}

