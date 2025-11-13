//
//  ProductCategory.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation


/// A logical grouping for products displayed in the admin panel.
///
/// Conforms to `Identifiable` for convenient use in SwiftUI lists.
struct ProductCategory: Codable, Hashable, Identifiable {
    /// Unique identifier of the category.
    let id: UUID
    /// Display name of the category.
    let name: String
}
