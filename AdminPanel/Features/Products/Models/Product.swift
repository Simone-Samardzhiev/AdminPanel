//
//  Product.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// A product offered by the restaurant.
///
/// Decodes from JSON where `price` is represented as a string to avoid floating
/// point issues. Conforms to `Identifiable` for SwiftUI lists.
struct Product: Decodable, Identifiable, Hashable, Equatable {
    /// Unique identifier of the product.
    let id: UUID
    /// Human-readable name of the product.
    var name: String
    /// Descriptive text for the product.
    var description: String
    /// Optional URL string pointing to the product image.
    var imageUrl: String?
    /// Identifier of the category this product belongs to.
    var category: UUID
    /// Product price represented as `Decimal` for precision.
    var price: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, imageUrl, category, price
    }
    
    /// Decodes a product from JSON, parsing `price` from a string into `Decimal`.
    /// - Throws: `DecodingError` if required fields are missing or malformed.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.category = try container.decode(UUID.self, forKey: .category)
        
        let stringPrice = try container.decode(String.self, forKey: .price)
        guard let price = Decimal(string: stringPrice) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.price, in: container, debugDescription: "Invalid price format")
        }
        self.price = price
    }
}
