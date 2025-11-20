//
//  ProductCategory.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation


/// Represents a product category returned by the API.
struct ProductCategory: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
}

/// Represents the payload required to add a new product category.
///
/// Used when adding  a new product category via `ProductServiceProtocol`
struct AddProductCategory: Encodable {
    let name: String
}

/// Represents the payload required to update a product category.
///
/// Used when updating a product category via `ProductServiceProtocol`
struct CategoryUpdate: Encodable {
    let id: UUID
    
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case newName
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .newName)
    }
}
