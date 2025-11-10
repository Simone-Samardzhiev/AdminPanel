//
//  APIClient.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation


/// Struct holding configuration for the API.
struct APIClient {
    let url: URL
    static let shared = Self(url: "http://127.0.0.1:8080/api/v1")
    
    init(url: String) {
        guard let parsedURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        self.url = parsedURL
    }
}
