//
//  AddProduct.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 17.11.25.
//

import Foundation

struct AddProduct: Encodable {
    /// Human-readable name of the product.
    var name: String
    /// Descriptive text for the product.
    var description: String
    /// Identifier of the category this product belongs to.
    var category: UUID?
    /// Product price represented as `Decimal` for precision.
    var price: Decimal
    
    init() {
        self.name = ""
        self.description = ""
        self.category = nil
        self.price = 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, description, category, price
    }
    
    /// Encodes the struct by encoding the `newPrice` property as `String`
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(price.description, forKey: .price)
    }
}
