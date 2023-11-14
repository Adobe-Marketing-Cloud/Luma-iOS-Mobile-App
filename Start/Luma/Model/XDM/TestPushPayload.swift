//
//  TestPushPayload.swift
//  Luma
//
//  Created by Rob In der Maur on 23/08/2023.
//
//   let testPushPayload = try? JSONDecoder().decode(TestPushPayload.self, from: jsonData)

import Foundation

// MARK: - TestPush
struct TestPushPayload: Codable {
    let application: Application
    let eventType: String
}

// MARK: - Application
struct Application: Codable {
    let id: String
}
