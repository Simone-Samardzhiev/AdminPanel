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
    case requestFailed(Error)
    
    /// Response was not a valid HTTP response.
    case invalidResponse
    
    /// The response status code was not expected.
    case invalidStatusCode(Int)

    /// The response body couldn't be decoded.
    case responseBodyDecodingFailed(Error)

    /// The request body couldn't be encoded.
    case bodyEncodingFailed(Error)
}

extension HTTPError {
    var userMessage: String {
        switch self {
        case .requestFailed:
            return "Couldn’t connect. Please check your internet and try again."
        default:
            return "Something went wrong. Please try again later."
        }
    }
}
