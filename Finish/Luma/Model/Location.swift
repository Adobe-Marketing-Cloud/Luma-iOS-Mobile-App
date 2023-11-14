//
//  Location.swift
//  Luma
//
//  Created by Rob In der Maur on 22/07/2022.
//

import Foundation
import MapKit

struct Location: Identifiable, Codable, Equatable {
    var id =  UUID()
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
    var identifier: String
    var category: String
    var street: String
    var city: String
    var state: String
    var country: String
    var countryCode: String
    var entryOrchestrationId: String
    var exitOrchestrationId: String

    // computed property foe location
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // always add an example for custom data types; makes it so much easier to use in previews, etc.
    static let example = Location(
        id: UUID(),
        name: "Buckingham Palace",
        description: "Where Queen Elizabeth lives with her dorgis.",
        latitude: 51.501,
        longitude: -0.141,
        identifier: "",
        category: "",
        street: "",
        city: "",
        state: "",
        country: "",
        countryCode: "",
        entryOrchestrationId: "",
        exitOrchestrationId: ""
        
    )

    // to compate locations to each other
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id

    }
}

