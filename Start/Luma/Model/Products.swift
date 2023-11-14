//
//  Products.swift
//  Luma
//
//  Created by Rob In der Maur on 27/05/2022.
//
//   let products = try? JSONDecoder().decode(Products.self, from: jsonData)

import Foundation

// MARK: - Products
struct Products: Codable {
    let products: [Product]
}

// MARK: - Product
struct Product: Identifiable, Codable {
    var id = UUID()
    let sku, name, category, color: String
    let size: String
    let price: Double
    let description: String
    let imageURL: String
    let url: String
    let stockQuantity: Int?
    let featured: Bool?

    enum CodingKeys: String, CodingKey {
        case sku, name, category, color, size, price, description
        case imageURL = "imageUrl"
        case url, stockQuantity
        case featured
    }
    
    static let example = Product(
        sku: "",
        name: "",
        category: "",
        color: "",
        size: "",
        price: 0.0,
        description: "",
        imageURL: "",
        url: "",
        stockQuantity: 0,
        featured: false
    )
}
