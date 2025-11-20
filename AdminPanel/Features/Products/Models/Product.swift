//
//  Product.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Represents a product retrieved from the backend API.
struct Product: Decodable, Identifiable, Hashable, Equatable {
    let id: UUID
    
    var name: String
    
    var description: String
    
    var imageUrl: String?
    
    var category: UUID
    
    var price: Decimal
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, imageUrl, category, price
    }
    
    /// Decodes a product from JSON, parsing `price` from a string into `Decimal`.
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
