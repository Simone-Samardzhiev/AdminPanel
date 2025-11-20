//
//  ProductUpdate.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 14.11.25.
//

import Foundation

/// Represents the payload required to update a product.
///
/// Used when updating a product via `ProductServiceProtocol`.
/// The `newPrice` is encoded as a string to preserve decimal precision.
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

        try container.encode(newName, forKey: .newName)
        try container.encode(newDescription, forKey: .newDescription)
        try container.encode(newCategory, forKey: .newCategory)

        if let price = newPrice {
            try container.encode(price.description, forKey: .newPrice)
        } else {
            try container.encodeNil(forKey: .newPrice)
        }
    }
}
