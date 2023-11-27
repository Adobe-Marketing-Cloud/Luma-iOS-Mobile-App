//
//  General.swift
//  Luma
//
//  Created by Rob In der Maur on 01/06/2022.
//

import Foundation

// MARK: - General
struct General: Codable {
    let config: Config
    let customer: Customer
    let testPush: TestPush
    let target: Target
    let map: AppMap
    
    static let example = General(
        config: Config(tenant: "", sandbox: "", showProducts: true, showPersonalisation: true, showGeofences: true, showBeacons: true, ldap: "", tms: "", emailDomain: ""),
        customer: Customer(name: "", logo: "", productsType: "", productsSystemImage: "", currency: "$"),
        testPush: TestPush(name: "", eventType: ""),
        target: Target(location: ""),
        map: AppMap(longitude: 0, latitude: 0, zoom: 0)
    )
}

struct Config: Codable {
    let tenant: String
    let sandbox: String
    let showProducts: Bool
    let showPersonalisation: Bool
    let showGeofences: Bool
    let showBeacons: Bool
    let ldap: String
    let tms: String
    let emailDomain: String?
    
    static let example = Config(tenant: "", sandbox: "", showProducts: true, showPersonalisation: true, showGeofences: true, showBeacons: true, ldap: "", tms: "", emailDomain: "adobetest.com")
}

struct Customer: Codable {
    let name, logo: String
    let productsType, productsSystemImage: String
    let currency: String
}

struct Target: Codable {
    let location: String
}

struct AppMap: Codable {
    let longitude: Double
    let latitude: Double
    let zoom: Double
}

// MARK: - TestOysg
struct TestPush: Codable {
    let name, eventType: String
}
