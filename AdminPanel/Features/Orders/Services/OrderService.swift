//
//  OrderService.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 12.12.25.
//

import Foundation

/// Abstraction over order-related API operations.
protocol OrderServiceProtocol {
    /// Fetches all order sessions.
    /// - Parameter credentials: Credentials used to authenticate.
    /// - Returns: Array of order sessions.
    /// - Throws: `HTTPError` if the request or decoding of the body fails.
    func getOrderSessions(credentials: Credentials) async throws(HTTPError) -> [OrderSession]
}

/// Default `OrderServiceProtocol` implementation using JSON and `URLSession`.
final class OrderService: OrderServiceProtocol {
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    
    /// Default initializer.
    /// - Parameters:
    ///   - jsonEncoder: Encoder used to encode data.
    ///   - jsonDecoder: Decoded used to decode data.
    init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
}

extension OrderService {
    /// Issues a GET request to `/admin/orders/sessions` and decodes the response.
    func getOrderSessions(credentials: Credentials) async throws(HTTPError) -> [OrderSession] {
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "sessions")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")
        request.cachePolicy = .returnCacheDataElseLoad
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await APIClient.shared.urlSession.data(for: request)
        } catch {
            throw .requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw .invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try jsonDecoder.decode([OrderSession].self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
}
