//
//  Configuration.swift
//  Luma
//
//  Created by Rob In der Maur on 30/05/2022.
//

import Foundation
import os.log

struct Network {
    static let shared = Network()
    
    /// Load products from a products.json file
    /// - Parameter configLocation: remote location where to find the products JSON structure
    /// - Returns: products
    func loadProducts(configLocation: String) async -> [Product] {
        if configLocation.isEmpty {
            if let aepProductsEndpoint = Bundle.main.url(forResource: "products", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: aepProductsEndpoint)
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(Products.self, from: data)
                    Logger.configuration.info("Network (local) - loadProducts load \(decodedResponse.products.count) products...")
                    return decodedResponse.products
                }
                catch {
                    return [Product]()
                }
            }
            return [Product]()
        }
        else {
            let aepProductsEndpoint = configLocation + "/products.json"
            Logger.configuration.info("Network - aepProductsEndpoint: \(aepProductsEndpoint)")
            
            guard let url = URL(string: aepProductsEndpoint) else {
                Logger.configuration.error("Network - loadProducts: Invalid URL.")
                return [Product]()
            }
            do {
                let (data, error) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(Products.self, from: data) {
                    Logger.configuration.info("Network - loadProducts load \(decodedResponse.products.count) products...")
                    return decodedResponse.products
                }
                else {
                    Logger.configuration.error("Network - loadProducts: Something wrong retrieving products, check JSON \(error.description)")
                    debugPrint("Error retrieving products: ", error)
                    return [Product]()
                }
            }
            catch {
                Logger.configuration.error("Network - loadProducts: Invalid data...\(error.localizedDescription)…")
                return [Product]()
            }
        }
    }
    
    /// Load decisions from a decisions.json file
    /// - Parameter configLocation: remote location where to find the decisions JSON structure
    /// - Returns: decision scopes
    func loadDecisions(configLocation: String) async -> Decisions {
        if configLocation.isEmpty {
            if let aepDecisionsEndpoint = Bundle.main.url(forResource: "decisions", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: aepDecisionsEndpoint)
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(Decisions.self, from: data)
                    Logger.configuration.info("Network (local) - loadDecisions loaded...")
                    return decodedResponse
                }
                catch {
                    return Decisions.example
                }
            }
            return Decisions.example
        }
        else {
            let aepDecisionsEndpoint = configLocation + "/decisions.json"
            Logger.configuration.info("Network - aepDecisionsEndpoint: \(aepDecisionsEndpoint)")
            
            guard let url = URL(string: aepDecisionsEndpoint) else {
                Logger.configuration.error("Network - loadDecisions: Invalid URL.")
                return Decisions.example
            }
            do {
                let (data, error) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(Decisions.self, from: data) {
                    Logger.configuration.info("Network - loadDecisions loaded...")
                    return decodedResponse
                }
                else {
                    Logger.configuration.error("Network - loadDecisions: Something wrong retrieving loadDecisions, check JSON \(error.description)")
                    return Decisions.example
                }
            }
            catch {
                Logger.configuration.error("Network - loadDecisions: Invalid data...\(error.localizedDescription)…")
                return Decisions.example
            }
        }
    }
    
    /// Load general config info from a general.json file
    /// - Parameter configLocation: remote location where to find the general JSON structure
    /// - Returns: general information
    func loadGeneral(configLocation: String) async -> General {
        if configLocation.isEmpty {
            if let aepGeneralEndpoint = Bundle.main.url(forResource: "general", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: aepGeneralEndpoint)
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(General.self, from: data)
                    Logger.configuration.info("Network (local) - loadGeneral loaded...")
                    return decodedResponse
                }
                catch {
                    return General.example
                }
            }
            return General.example
        }
        else {
            let aepGeneralEndpoint = configLocation + "/general.json"
            Logger.configuration.info("Network - loadGeneral: aepGeneralEndpoint: \(aepGeneralEndpoint)")
            
            guard let url = URL(string: aepGeneralEndpoint) else {
                Logger.configuration.error("Network - loadGeneral: Invalid URL.")
                return General.example
            }
            do {
                let config = URLSessionConfiguration.default
                config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                let session = URLSession(configuration: config)
                let (data, error) = try await session.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(General.self, from: data) {
                    Logger.configuration.info("Network - loadGeneral loaded...")
                    return decodedResponse
                }
                else {
                    Logger.configuration.error("Network - Something wrong with the getting the decoded response: \(error.description)")
                    return General.example
                }
            }
            catch {
                Logger.configuration.error("Network - loadGeneral: Invalid data...\(error.localizedDescription)…")
                return General.example
            }
        }
    }
    
    /// Load beacon configuration from a beacons.json file
    /// - Parameter configLocation: remote location where to find the beacons JSON structure
    /// - Returns: beacons
    func loadIBeacons(configLocation: String) async -> [IBeacon] {
        if configLocation.isEmpty {
            if let aepIBeaconsEndpoint = Bundle.main.url(forResource: "ibeacons", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: aepIBeaconsEndpoint)
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(IBeacons.self, from: data)
                    Logger.configuration.info("Network (local) - loadBeacons - Found \(decodedResponse.ibeacons.count) beacons…")
                    return decodedResponse.ibeacons
                }
                catch {
                    return [IBeacon]()
                }
            }
            return [IBeacon]()
        }
        else {
            let aepIBeaconsEndpoint = configLocation + "/ibeacons.json"
            
            guard let url = URL(string: aepIBeaconsEndpoint) else {
                Logger.configuration.error("Network - loadIBeacons: Invalid URL.")
                return [IBeacon]()
            }
            do {
                let (data, error) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(IBeacons.self, from: data) {
                    Logger.configuration.info("Network - loadBeacons - Found \(decodedResponse.ibeacons.count) beacons…")
                    return decodedResponse.ibeacons
                }
                else {
                    Logger.configuration.error("Network - loadBeacons: Something wrong retrieving beacons, check JSON \(error.description)")
                    return [IBeacon]()
                }
            }
            catch {
                Logger.configuration.error("Network - loadBeacons: Invalid data...\(error.localizedDescription)…")
                return [IBeacon]()
            }
        }
    }
}

