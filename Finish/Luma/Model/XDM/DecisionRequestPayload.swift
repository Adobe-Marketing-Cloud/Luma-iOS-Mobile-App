//
//  DecisionRequestPayload.swift
//  Luma
//
//  Created by Rob In der Maur on 05/01/2023.
//

import Swift

// MARK: - Welcome
struct DecisionRequestPayload: Codable {
    let xdmPropositionRequests: [XDMPropositionRequest]
    let xdmProfiles: [XDMProfile]
    let xdmAllowDuplicatePropositions: XDMAllowDuplicatePropositions
    let xdmResponseFormat: XDMResponseFormat
    let xdmIncludeMetadata: XDMIncludeMetadata
    let xdmDryRun: Bool

    enum CodingKeys: String, CodingKey {
        case xdmPropositionRequests = "xdm:propositionRequests"
        case xdmProfiles = "xdm:profiles"
        case xdmAllowDuplicatePropositions = "xdm:allowDuplicatePropositions"
        case xdmResponseFormat = "xdm:responseFormat"
        case xdmIncludeMetadata = "xdm:includeMetadata"
        case xdmDryRun = "xdm:dryRun"
    }
}

// MARK: - XDMAllowDuplicatePropositions
struct XDMAllowDuplicatePropositions: Codable {
    let xdmAcrossActivities, xdmAcrossPlacements: Bool

    enum CodingKeys: String, CodingKey {
        case xdmAcrossActivities = "xdm:acrossActivities"
        case xdmAcrossPlacements = "xdm:acrossPlacements"
    }
}

// MARK: - XDMIncludeMetadata
struct XDMIncludeMetadata: Codable {
    let xdmActivity, xdmOption, xdmPlacement: [String]

    enum CodingKeys: String, CodingKey {
        case xdmActivity = "xdm:activity"
        case xdmOption = "xdm:option"
        case xdmPlacement = "xdm:placement"
    }
}

// MARK: - XDMProfile
struct XDMProfile: Codable {
    let xdmIdentityMap: XDMIdentityMap

    enum CodingKeys: String, CodingKey {
        case xdmIdentityMap = "xdm:identityMap"
    }
}

// MARK: - XDMIdentityMap
struct XDMIdentityMap: Codable {
    let ecid: [Ecid]

    enum CodingKeys: String, CodingKey {
        case ecid = "ECID"
    }
}

// MARK: - Ecid
struct Ecid: Codable {
    let xdmID: String

    enum CodingKeys: String, CodingKey {
        case xdmID = "xdm:id"
    }
}

// MARK: - XDMPropositionRequest
struct XDMPropositionRequest: Codable {
    let xdmPlacementID, xdmActivityID: String
    let xdmItemCount: Int

    enum CodingKeys: String, CodingKey {
        case xdmPlacementID = "xdm:placementId"
        case xdmActivityID = "xdm:activityId"
        case xdmItemCount = "xdm:itemCount"
    }
}

// MARK: - XDMResponseFormat
struct XDMResponseFormat: Codable {
    let xdmIncludeContent: Bool

    enum CodingKeys: String, CodingKey {
        case xdmIncludeContent = "xdm:includeContent"
    }
}
