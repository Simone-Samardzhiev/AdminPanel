//
//  ImageUpdate.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import Foundation

/// Struct holding response information from the API when replacing an image.
struct ImageUpdate: Decodable {
    let url: String
}
