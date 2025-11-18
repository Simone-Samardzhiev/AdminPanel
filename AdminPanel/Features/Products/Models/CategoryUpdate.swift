//
//  CategoryUpdate.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.11.25.
//

import Foundation


/// Struct holding category updates info.
struct CategoryUpdate: Encodable {
    let id: UUID
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case newName
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .newName)
    }
}
