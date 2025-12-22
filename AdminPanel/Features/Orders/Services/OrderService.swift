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
    
    /// Creates a new order session.
    /// - Parameter credentials: Credentials used to authenticate.
    /// - Returns: The newly created session.
    func createSession(credentials: Credentials) async throws(HTTPError) -> OrderSession
    
    
    /// Deletes a order session by id.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - id: The id of the session.
    func deleteSession(credentials: Credentials, id: UUID) async throws(HTTPError)
    
    
    /// Fetches all ordered products.
    /// - Parameter credentials: Credentials used to authenticate.
    func getOrderedProducts(credentials: Credentials) async throws(HTTPError) -> [OrderedProduct]
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
        let url = APIClient.shared.restURL
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "sessions")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")
        
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
    
    /// Issues a POST request to `/admin/orders/sessions` and decodes the response.
    func createSession(credentials: Credentials) async throws(HTTPError) -> OrderSession {
        let url = APIClient.shared.restURL
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "sessions")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")
        
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
            return try jsonDecoder.decode(OrderSession.self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
    
    /// Issues a DELETE request to `/admin/orders/sessions/{id}` and decodes the response.
    func deleteSession(credentials: Credentials, id: UUID) async throws(HTTPError) {
        let url = APIClient.shared.restURL
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "sessions")
            .appending(path: id.uuidString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")
        
        let response: URLResponse
        
        do {
            (_, response) = try await APIClient.shared.urlSession.data(for: request)
        } catch {
            throw .requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw .invalidStatusCode(httpResponse.statusCode)
        }
    }
    
    /// Issues a GET request to `/admin/orders/ordered-products` and decodes the response.
    func getOrderedProducts(credentials: Credentials) async throws(HTTPError) -> [OrderedProduct] {
        let url = APIClient.shared.restURL
            .appending(path: "admin")
            .appending(path: "orders")
            .appending(path: "ordered-products")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIClient.encodeCredentials(credentials), forHTTPHeaderField: "Authorization")
        
        
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
            return try jsonDecoder.decode([OrderedProduct].self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
}
