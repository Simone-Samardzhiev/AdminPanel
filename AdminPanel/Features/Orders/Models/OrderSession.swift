//
//  OrderSession.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 12.12.25.
//

import Foundation



/// Represents an order session.
struct OrderSession: Decodable, Identifiable {
    /// Order session statuses.
    enum Status: String, Codable, CaseIterable {
        case open = "open"
        case closed = "closed"
        case paid = "paid"
    }
    
    let id: UUID
    var tableNumber: Int
    var status: Status
}
