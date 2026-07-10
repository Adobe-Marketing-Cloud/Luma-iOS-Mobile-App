//
//  CodeBasedOffer.swift
//  Luma
//
//  Created using Claude Code
//

import Foundation

// Model for parsing code-based experience content with decisioning offers
struct CodeBasedContent: Codable {
    let version: String?
    let offers: [DecisioningOffer]?
    
    enum CodingKeys: String, CodingKey {
        case version
        case offers // Maps to "offers" (plural) in JSON response from AJO template
    }
}

struct DecisioningOffer: Codable, Identifiable {
    let id: String
    let name: String?
    let title: String?
    let text: String?
    let image: String?
    let actionUrl: String?
    
    // Custom init to provide default id if not present in JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Use provided id or generate UUID if missing
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.actionUrl = try container.decodeIfPresent(String.self, forKey: .actionUrl)
    }
    
    // Add any other custom characteristics from your offers
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case title
        case text
        case image
        case actionUrl
    }
}
