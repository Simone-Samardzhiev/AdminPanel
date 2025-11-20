//
//  AddProduct.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 17.11.25.
//

import Foundation

/// Represents the payload required to create a new product.
///
/// Used when adding a new product via `ProductServiceProtocol`.
/// The `price` is encoded as a string to preserve decimal precision.
struct AddProduct: Encodable {
    var name: String
    
    var description: String

    var category: UUID
    
    var price: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case name, description, category, price
    }
    
    /// Encodes the product for sending in API requests.
    ///
    /// Converts the `price` property from `Decimal` to `String` to preserve precision in JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(price.description, forKey: .price)
    }
    
    
    /// Validates the product’s fields.
    ///
    /// Checks the following conditions:
    /// - `name` must be between 3 and 100 characters.
    /// - `description` must be at least 15 characters.
    /// - `price` must be greater than 0 and less than 999999.99.
    ///
    /// - Returns: An optional error message as a `String`.
    ///            Returns `nil` if all validations pass, or a descriptive
    ///            error message if a validation fails.
    func validate() -> String? {
        guard (3...100).contains(name.count) else {
            return "Name should be between 3 and 100 characters!"
        }
        
        guard description.count >= 15 else {
            return "Description should be more than 15 characters!"
        }
        
        guard price > 0 else {
            return "Price should be more than 0!"
        }
        
        guard price < 999999.99 else {
            return "Price should be less than 999999.99!"
        }
        
        return nil
    }

}
