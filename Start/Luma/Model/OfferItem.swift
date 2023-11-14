//
//  OfferItem.swift
//  Luma
//
//  Created by Rob In der Maur on 08/09/2023.
//

import Foundation
import AEPOptimize


// MARK: - Content
struct OfferItem: Codable {
    let offer: Offer
    let content: ContentItem
}
