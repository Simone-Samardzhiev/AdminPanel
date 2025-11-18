//
//  ProductUpdate.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 14.11.25.
//

import Foundation

/// Struct holding product update information.
struct ProductUpdate: Encodable {
    let id: UUID
    let newName: String?
    let newDescription: String?
    let newCategory: UUID?
    let newPrice: Decimal?

    enum CodingKeys: String, CodingKey {
        case newName
        case newDescription
        case newCategory
        case newPrice
    }
    
    /// Encodes the struct by encoding the `newPrice` property as `String`
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(newName, forKey: .newName)
        try container.encodeIfPresent(newDescription, forKey: .newDescription)
        try container.encodeIfPresent(newCategory, forKey: .newCategory)

        if let price = newPrice {
            try container.encode(price.description, forKey: .newPrice)
        } else {
            try container.encodeNil(forKey: .newPrice)
        }
    }
}
