//
//  OrderWebSocketService.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 20.12.25.
//

import Foundation

/// Protocol for abstraction over WebSocket connection.
protocol OrderWebSocketServiceProtocol {
    /// Strats listening to the connect and yields received events.
    /// - Returns: Streams of the events.
    func connect(_ credentials: Credentials) -> AsyncThrowingStream<WebSocketEvent, Error>
}

final class OrderWebSocketService: OrderWebSocketServiceProtocol {
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// Initializer with custom json decoder and encoder.
    /// - Parameters:
    ///   - jsonEncoder: Json encoder.
    ///   - jsonDecoder: Json decoder.
    init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.webSocketTask = nil
    }
}

extension OrderWebSocketService {
    func connect(_ credentials: Credentials) -> AsyncThrowingStream<WebSocketEvent, Error> {
        let (stream, continuation) = AsyncThrowingStream
            .makeStream(of: WebSocketEvent.self)
        
        let url = APIClient.shared.webSocketURL
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "connect")
        
        var request = URLRequest(url: url)
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")

        self.webSocketTask = APIClient.shared.urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        
        Task {
            await listen(continuation)
        }
        
        continuation.onTermination = { @Sendable _ in
            Task { await self.disconnect() }
        }
        
        return stream
    }
    
    /// Function that listen for WebSocket message and yields decoded event.
    /// - Parameter continuation: Continuation to which the WebSocket events will be send.
    private func listen(_ continuation: AsyncThrowingStream<WebSocketEvent, Error>.Continuation) async {
        guard let task = webSocketTask else {
            return
        }
        
        while task.state == .running {
            do {
                let message = try await task.receive()
                
                switch message {
                case .data(_):
                    break
                case .string(let text):
                    guard let data = text.data(using: .utf8) else {
                        break
                    }
                    
                    let event = try jsonDecoder.decode(WebSocketEvent.self, from: data)
                    continuation.yield(event)
                @unknown default:
                    break
                }
            } catch {
                continuation.yield(with: .failure(error))
            }
        }
    }
    
    /// Function to stop the listening for messages from the WebSocket connection.
    private func disconnect() async {
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
