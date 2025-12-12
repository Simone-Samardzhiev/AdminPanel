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
    
    /// The default url session.
    let urlSession: URLSession
    
    /// Shared instance pointing at the local development server.
    static let shared = Self(url: "http://127.0.0.1:8080/api/v1")
    
    /// Creates a new client from a base URL string.
    /// - Parameter url: The base URL string. Triggers a runtime `fatalError` if invalid.
    init(url: String) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        self.url = parsedURL
        
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024
        )
        
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .useProtocolCachePolicy
        config.httpShouldSetCookies = true
        
        self.urlSession = URLSession(configuration: config)
    }
}

