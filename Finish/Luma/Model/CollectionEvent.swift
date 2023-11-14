//
//  CollectionEvent.swift
//  Amsiossa
//
//  Created by Rob In der Maur on 29/06/2022.
//

import Foundation


/*
// MARK: - CollectionEvent
struct CollectionEvent: Codable {
    let events: Events
    let query: Query
}

// MARK: - Event
struct Events: Codable {
    let xdm: XDM
}

// MARK: - XDM
struct XDM: Codable {
    enum CodingKeys: IdentityMapAlt, CodingKey {
        case identityMapAlt = "identityMap"
    }
    let identityMapAlt: IdentityMapAlt
}

// MARK: - IdentityMap
struct IdentityMapAlt: Codable {
    let ecid: [Ecid]

    enum CodingKeys: String, CodingKey {
        case ecid
    }
}

// MARK: - Ecid
struct Ecid: Codable {
    let id: String
    let primary: Bool
}

// MARK: - Query
struct Query: Codable {
    let personalization: Personalization
}

// MARK: - Personalization
struct Personalization: Codable {
    let schemas: [String]
    let decisionScopes: [String]
}
*/

import Foundation

// MARK: - EdgeResponse
struct XDMData: Codable {
    let identityMapAlt: IdentityMapAlt
    
    enum CodingKeys: String, CodingKey {
        case identityMapAlt = "identifyMap"
    }
}

// MARK: - IdentityMap
struct IdentityMapAlt: Codable {
    let ecid: [Ecid]

    enum CodingKeys: String, CodingKey {
        case ecid = "ECID"
    }
}

// MARK: - Ecid
struct Ecid: Codable {
    let id: String
    let primary: Bool
}
