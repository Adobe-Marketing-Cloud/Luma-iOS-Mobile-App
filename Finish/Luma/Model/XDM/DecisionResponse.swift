//
//  DecisionResponse.swift
//  Luma
//
//  Created by Rob In der Maur on 23/12/2022.
//

import Swift

struct DecisionResponse: Codable {
    let propositionId : String
    let propositions: [Proposition]
    let createDate: Int64
    
    enum CodingKeys: String, CodingKey {
        case propositionId = "xdm:propositionID"
        case propositions = "xdm:propositions"
        case createDate = "ode:createDate"
    }
}

struct Proposition: Codable {
    let activity: Activity
    let placement: Placement
    let scope: String
    let options: [Option]?
    let fallback: Option?
    
    enum CodingKeys: String, CodingKey {
        case activity = "xdm:activity"
        case placement = "xdm:placement"
        case scope = "xdm:scope"
        case options = "xdm:options"
        case fallback = "xdm:fallback"
    }
}

struct Activity: Codable {
    let id: String
    let etag: String
    
    enum CodingKeys: String, CodingKey {
        case id = "xdm:id"
        case etag = "repo:etag"
    }
}

struct Placement: Codable {
    let id: String
    let etag: String
    
    enum CodingKeys: String, CodingKey {
        case id = "xdm:id"
        case etag = "repo:etag"
    }
}

struct Option: Codable {
    let id: String
    let etag: String
    let type: String
    let format: String?
    let language: [String]?
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case id = "xdm:id"
        case etag = "repo:etag"
        case type = "@type"
        case format = "dc:format"
        case language = "dc:language"
        case content = "xdm:content"
    }
}
