//
//  Image.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import Foundation

/// Represents the API response returned after successfully replacing
/// an image on the server.
struct ImageUpdate: Decodable {
    let url: String
}
