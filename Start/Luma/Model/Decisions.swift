//
//  Decisions.swift
//  Luma
//
//  Created by Rob In der Maur on 21/12/2022.
//

import AEPOptimize
import Foundation

// MARK: - Products
struct Decisions: Codable {
    let apiKey: String
    let clientSecret: String
    let scopes: String
    let orgId: String
    let containerId: String
    let allowDuplicatesAcrossActivities: Bool
    let allowDuplicatesAcrossPlacements: Bool
    let dryRun: Bool
    let decisionScopes: [Decision]
    
    static let example = Decisions(
        apiKey: "",
        clientSecret: "",
        scopes: "",
        orgId: "",
        containerId: "",
        allowDuplicatesAcrossActivities: false,
        allowDuplicatesAcrossPlacements:false,
        dryRun: false,
        decisionScopes: [Decision(name: "", activityId: "", placementId: "", itemCount: 0)]
    )
}

// MARK: - Decision
struct Decision: Codable {
    let name: String?
    let activityId: String
    let placementId: String
    let itemCount: Int
}
