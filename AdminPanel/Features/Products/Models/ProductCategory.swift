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
