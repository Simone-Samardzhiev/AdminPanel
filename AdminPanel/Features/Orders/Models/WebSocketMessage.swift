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
    
    /// Delete event represents a deleted ordered product.
    case delete(Delete)
    
    /// Update order session event represents update of order session.
    case updateOrderSession(OrderSessionUpdate)
    
    /// Paid session event represent session has been paid.
    case sessionPaid(SessionPaid)
    
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
        case .delete:
            let data = try container.decode(Delete.self, forKey: .data)
            self = .delete(data)
        case .orderSessionUpdate:
            let data = try container.decode(OrderSessionUpdate.self, forKey: .data)
            self = .updateOrderSession(data)
        case .sessionPaid:
            let data = try container.decode(SessionPaid.self, forKey: .data)
            self = .sessionPaid(data)
        }
    }
    
}

extension WebSocketEvent {
    /// Enum representing different events.
    private enum Events: String, Decodable {
        case order = "ORDER_OK"
        case delete = "DELETE_ORDERED_PRODUCT_OK"
        case orderSessionUpdate = "UPDATE_SESSION_OK"
        case sessionPaid = "PAY_OK"
    }
    
    /// Order event payload.
    struct Order: Decodable {
        let id: UUID
        let productId: UUID
        let sessionId: UUID
        let status: OrderedProduct.Status
    }
    
    /// Delete ordered product payload.
    struct Delete: Decodable {
        let id: UUID
    }
    
    /// Update order session payload.
    struct OrderSessionUpdate: Decodable {
        let id: UUID
        let tableNumber: Int
        let status: OrderSession.Status
    }
    
    /// Paid session payload.
    struct SessionPaid: Decodable {
        let id: UUID
    }
}

/// Messages send from the app.
enum WebSocketOutgoingMessage: Encodable {
    /// Delete message for deleting an ordered product.
    case delete(DeletePayload)
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .delete(let payload):
            try container.encode(MessageType.delete, forKey: .type)
            try container.encode(payload, forKey: .data)
        }
    }
}

extension WebSocketOutgoingMessage {
    /// Enum representing message types.
    private enum MessageType: String, Encodable {
        case delete = "DELETE_ORDERED_PRODUCT"
    }
    
    /// Payload for deleting an ordered product.
    struct DeletePayload: Encodable {
        let id: UUID
    }
}
