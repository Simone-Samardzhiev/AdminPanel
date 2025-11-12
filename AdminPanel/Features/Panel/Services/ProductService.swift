//
//  ProductService.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Abstraction over product-related API operations.
///
/// Provides methods to load product categories and products for a category.
protocol ProductServiceProtocol {
    /// Fetches all available product categories.
    /// - Returns: An array of `ProductCategory` on success.
    /// - Throws: `HTTPError` when the request or decoding fails.
    func getProductCategories() async throws(HTTPError) ->[ProductCategory]
    
    /// Fetches products for a given category.
    /// - Parameter categoryId: The category identifier.
    /// - Returns: An array of `Product` on success.
    /// - Throws: `HTTPError` when the request or decoding fails.
    func getProducts(_ categoryId: UUID) async throws(HTTPError) -> [Product]
}

/// Default `ProductServiceProtocol` implementation using `URLSession` and JSON coders.
final class ProductService {
    /// JSON encoder used for encoding payloads when needed.
    let jsonEncoder: JSONEncoder
    
    /// JSON decoder used to parse responses from the API.
    let jsonDecoder: JSONDecoder
    
    /// Creates a new service with the provided JSON coders.
    /// - Parameters:
    ///   - jsonEncoder: Encoder for outgoing payloads.
    ///   - jsonDecoder: Decoder for incoming responses.
    init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
}

extension ProductService: ProductServiceProtocol {
    /// Issues a GET request to `/public/product-categories` and decodes the response.
    func getProductCategories() async throws(HTTPError) -> [ProductCategory] {
        let url = APIClient.shared.url.appending(path: "/public/product-categories")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: Data
        
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw HTTPError.requestFailed
        }
        
        let productCategories: [ProductCategory]
        do {
            try productCategories = jsonDecoder.decode([ProductCategory].self, from: data)
        } catch {
            throw HTTPError.invalidResponse
        }
        
        return productCategories
    }
    
    /// Issues a GET request to `/public/products?category_id=...` and decodes the response.
    func getProducts(_ categoryId: UUID) async throws(HTTPError) -> [Product] {
        var url = APIClient.shared.url.appending(path: "/public/products")
        url = url.appending(queryItems: [URLQueryItem(name: "category_id", value: categoryId.uuidString)])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: Data
        
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw HTTPError.requestFailed
        }
        
        let products: [Product]
        do {
            try products = jsonDecoder.decode([Product].self, from: data)
        } catch {
            throw HTTPError.invalidResponse
        }
        
        return products
    }

} 

