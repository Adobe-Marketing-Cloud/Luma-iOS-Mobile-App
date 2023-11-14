//
//  AccessTokenResponse.swift
//  Luma
//
//  Created by Rob In der Maur on 25/09/2023.
//   let accessTokenResponse = try? JSONDecoder().decode(AccessTokenResponse.self, from: jsonData)

import Foundation

// MARK: - AccessTokenResponse
struct AccessTokenResponse: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
