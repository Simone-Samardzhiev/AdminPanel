//
//  OrderedProduct.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import Foundation

struct OrderedProduct: Decodable, Identifiable {
    /// Status of ordered pro
    enum Status: String, Decodable, CaseIterable {
        case pending = "pending"
        case preparing = "preparing"
        case done = "done"
    }
    
    let id: UUID
    let productId: UUID
    let status: Status
    let orderSessionId: UUID
}
