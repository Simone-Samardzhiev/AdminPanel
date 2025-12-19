//
//  APIClient.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation


/// A tiny API client configuration holder.
///
/// `APIClient` exposes a base `url` used by services to construct endpoint URLs.
/// A shared instance is provided via `APIClient.shared`.
struct APIClient {
    /// The base URL for all API endpoints.
    let url: URL
    
    let urlSession: URLSession
    
    /// Shared instance.
    static let shared = Self(url: "http://192.168.1.8:8080/api/v1")
    
    /// Creates a new client from a base URL string.
    /// - Parameter url: The base URL string. Triggers a runtime `fatalError` if invalid.
    init(url: String) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        self.url = parsedURL
        self.urlSession = URLSession(configuration: .default)
    }
    
    static func encodeCredentials(_ credentials: Credentials) -> String {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
    
        return "Basic \(credentialsData.base64EncodedString())"
    }
}

