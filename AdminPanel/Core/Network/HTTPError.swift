//
//  HTTPError.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Common HTTP-layer errors used by networking services in the app.
///
/// These cases intentionally avoid leaking transport details into higher layers.
enum HTTPError: Error, LocalizedError {
    /// The request could not be completed (e.g., connectivity or timeout).
    case requestFailed
    /// The response was not valid or could not be decoded.
    case invalidResponse
    
    var failureReason: String? {
        switch self {
        case .requestFailed:
            return "The request could not be completed."
        case .invalidResponse:
            return "The response was not valid or could not be decoded."
        }
    }
}

extension HTTPError {
    var userMessage: String {
        switch self {
        case .requestFailed:
            return "Couldn’t connect. Please check your internet and try again."
        case .invalidResponse:
            return "Something went wrong. Please try again later."
        }
    }
}
