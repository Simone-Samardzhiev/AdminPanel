//
//  WebSocketMessage.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 20.12.25.
//

import Foundation

/// Enum representing events from the WebSocket connection.
enum WebSocketEvent: Decodable {
    /// Order event represent a new ordered product.
    case order(Order)
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(Events.self, forKey: .type)
        switch type {
        case .order:
            let data = try container.decode(Order.self, forKey: .data)
            self = .order(data)
        }
    }
    
}

extension WebSocketEvent {
    /// Enum representing different events.
    private enum Events: String, Decodable {
        case order = "ORDER_OK"
    }
    
    /// Order event payload.
    struct Order: Decodable {
        let id: UUID
        let productId: UUID
        let sessionId: UUID
        let status: OrderedProduct.Status
    }
}
