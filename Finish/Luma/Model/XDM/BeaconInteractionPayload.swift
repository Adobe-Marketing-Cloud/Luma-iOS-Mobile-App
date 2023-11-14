//
//  ExperienceEvent.swift
//  Luma
//
//  Created by Rob In der Maur on 22/09/2022.
//

import SwiftUI

struct BeaconInteractionPayload: Codable {
    let placeContext: PlaceContext
    let eventType: String
    
    enum CodingKeys: String, CodingKey {
        case placeContext
        case eventType
    }
}

// MARK: - PlaceContext
struct PlaceContext: Codable {
    let poIinteraction: POIinteraction?
    
    enum CodingKeys: String, CodingKey {
        case poIinteraction = "POIinteraction"
    }
}

// MARK: - POIinteraction
struct POIinteraction: Codable {
    let poiDetail: PoiDetail
    let poiEntries: PoiEntries
    let poiExits: PoiExits
}

// MARK: - PoiDetail
struct PoiDetail: Codable {
    let name, poiID, locatingType, category: String
    let beaconInteractionDetails: BeaconInteractionDetails
}

// MARK: - PoiEntries
struct PoiEntries: Codable {
    let value: Double
}

// MARK: - PoiEntries
struct PoiExits: Codable {
    let value: Double
}

struct BeaconInteractionDetails: Codable {
    let beaconMajor: Double
    let beaconMinor: Double
}
