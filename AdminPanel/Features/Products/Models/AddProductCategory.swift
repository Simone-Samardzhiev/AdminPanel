//
//  AddCategory.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.11.25.
//

import Foundation


/// Represents the payload required to add a new product category.
///
/// Used when adding  a new product category via `ProductServiceProtocol`
struct AddProductCategory: Encodable {
    let name: String
}
