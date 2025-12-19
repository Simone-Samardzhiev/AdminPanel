//
//  UserRepresentableError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.12.25.
//

import Foundation

/// Protocol for error that should be present to the user.
protocol UserRepresentableError: Error {
    var userMessage: String { get }
}
