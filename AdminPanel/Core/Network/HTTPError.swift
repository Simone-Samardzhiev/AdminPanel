//
//  HTTPError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Common HTTP errors.
enum HTTPError: Error {
    case requestFailed
    case invalidResponse
}
