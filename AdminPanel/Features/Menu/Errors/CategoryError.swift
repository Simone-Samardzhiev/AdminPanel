//
//  CategoryError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.12.25.
//

import Foundation


/// Enum representing possible error when interacting with categories data.
enum CategoryError: Error, LocalizedError, UserRepresentableError {
    /// Name of the category is invalid.
    case invalidName
    
    /// Name of the category is already in use.
    case duplicateName
    
    /// Network error occurred.
    case network(HTTPError)
}

extension CategoryError {
    var userMessage: String {
        switch self {
        case .invalidName: "Name should be between 4 and 100 characters!"
        case .duplicateName: "Category with this name is already exists!"
        case .network(let error): error.userMessage
        }
    }
}
