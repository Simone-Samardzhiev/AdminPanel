//
//  ProductError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 19.12.25.
//

import Foundation


/// Enum representing possible error when interacting with products data.
enum ProductError: Error, LocalizedError, UserRepresentableError {
    /// Name of the products is invalid.
    case invalidName
    
    /// Name of the products is already in use.
    case duplicateName
    
    /// Description of the product is invalid.
    case invalidDescription
    
    /// Price of the product is invalid.
    case invalidPrice
    
    /// Product was not found.
    case productNotFound
    
    /// Network error occurred.
    case network(HTTPError)
}

extension ProductError {
    var userMessage: String {
        switch self {
        case .invalidName: "Name should be between 3 and 100 characters!"
        case .duplicateName: "Product name is already in use!"
        case .invalidDescription: "Description should be more than 15 characters!"
        case .invalidPrice: "Price should be greater than zero!"
        case .productNotFound: "Product not found!"
        case .network(let error): error.userMessage
        }
    }
}
