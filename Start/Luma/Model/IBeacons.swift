//
//  IBeacons.swift
//  Luma
//
//  Created by Rob In der Maur on 27/07/2022.
//

import Foundation
import CoreLocation

// MARK: - IBeacons
struct IBeacons: Codable {
    var ibeacons: [IBeacon]
    
    enum CodingKeys: String, CodingKey {
        case ibeacons = "ibeacons"
    }
}

// MARK: - Ibeacon
struct IBeacon: Codable {
    let uuid: String
    let major, minor: Double
    let identifier, title, location: String
    let category: String?
    var status, symbol: String
    
    mutating func setStatus(withStatus newStatus: String) {
        status = newStatus
    }
    
    mutating func setSymbol(withSymbol newSymbol: String) {
        symbol = newSymbol
    }
}
