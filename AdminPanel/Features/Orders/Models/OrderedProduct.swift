//
//  OrderedProduct.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import Foundation

struct OrderedProduct: Decodable, Identifiable {
    /// Status of ordered product.
    enum Status: String, Decodable, CaseIterable {
        case pending = "pending"
        case preparing = "preparing"
        case done = "done"
    }
    
    let id: UUID
    let productId: UUID
    var status: Status
    let orderSessionId: UUID
}
