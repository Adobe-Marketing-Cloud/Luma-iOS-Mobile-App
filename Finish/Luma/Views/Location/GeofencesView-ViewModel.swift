//
//  GeofencesView-ViewModel.swift
//  Luma
//
//  Created by Rob In der Maur on 24/07/2022.
//

import AEPPlaces
import Foundation
import LocalAuthentication
import MapKit
import os.log

extension GeofencesView {
    
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.37109, longitude: 4.8919), span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
        @Published var locations: [Location]
        @Published var region: CLCircularRegion?
        
        
        init() {
            locations = []
        }
        
        @MainActor
        func setLocation(configLocation: String) async {
            // clear locations
            DispatchQueue.main.async {
                self.locations = []
            }
            
            // set location to where center of map is
            var location = Location(id: UUID(), name: "", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude, identifier: "", category: "", street: "", city: "", state: "", country: "", countryCode: "", entryOrchestrationId: "", exitOrchestrationId: "")
            
            // figure out whether the location is in one of the defined Places POI's
            Places.getNearbyPointsOfInterest(forLocation: CLLocation(latitude: location.latitude, longitude: location.longitude), withLimit: 200) { pointsOfInterests, PlacesQueryResponseCode in
                for pointsOfInterest in pointsOfInterests {
                    Logger.aepMobileSDK.info("GeofencesView - setLocation: POI - Response code...: \(PlacesQueryResponseCode.rawValue)")
                    // if so give locatio name of point of interest
                    Logger.aepMobileSDK.info("GeofencesView - setLocation: POI - Nearby point of interest...: \(pointsOfInterest.name)")
                    location.name = pointsOfInterest.name
                    location.description = pointsOfInterest.description
                    location.latitude = pointsOfInterest.latitude
                    location.longitude = pointsOfInterest.longitude
                    location.identifier = pointsOfInterest.identifier
                    location.category = (pointsOfInterest.metaData["category"] ?? "") as String
                    location.street = (pointsOfInterest.metaData["street"] ?? "") as String
                    location.city = (pointsOfInterest.metaData["city"] ?? "") as String
                    location.state = (pointsOfInterest.metaData["state"] ?? "") as String
                    location.country = (pointsOfInterest.metaData["country"] ?? "") as String
                    location.countryCode = (pointsOfInterest.metaData["countryCode"] ?? "") as String
                    location.entryOrchestrationId = (pointsOfInterest.metaData["entryOrchestrationId"] ?? "") as String
                    location.exitOrchestrationId = (pointsOfInterest.metaData["exitOrchestrationId"] ?? "") as String
                    Logger.configuration.info("GeofencesView - setLocation: POI - location description: \(location.description)")
                    
                    // set region to POI
                    DispatchQueue.main.async {
                        self.region = CLCircularRegion(center: CLLocationCoordinate2DMake(location.latitude, location.longitude), radius: 100, identifier: location.identifier)
                    }
                }
                Logger.configuration.info("GeofencesView - setLocation: POI - Adding location: \(location.description)")
                DispatchQueue.main.async {
                    self.locations.append(location)
                }
            }
        }
    }
}
