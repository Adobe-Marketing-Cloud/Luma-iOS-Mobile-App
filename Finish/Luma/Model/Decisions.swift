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
    let decisionScopes: [Decision]
    
    static let example = Decisions(
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
