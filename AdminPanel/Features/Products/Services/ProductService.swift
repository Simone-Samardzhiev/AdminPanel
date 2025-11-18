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
    func getProductCategories() async throws(HTTPError) -> [ProductCategory]
    
    /// Fetches all products.
    /// - Returns: An array of `Products` on success.
    /// - Throws: `HTTPError` when the request or decoding fails.
    func getProducts() async throws(HTTPError) -> [Product]
    
    /// Fetches products for a given category.
    /// - Parameter categoryId: The category identifier.
    /// - Returns: An array of `Product` on success.
    /// - Throws: `HTTPError` when the request or decoding fails.
    func getProductsByCategory(_ categoryId: UUID) async throws(HTTPError) -> [Product]
    
    
    /// Adds a new category
    /// - Parameter category: The category name.
    /// - Returns: The created category.
    func addCategory(credentials: Credentials, category: AddCategory) async throws(HTTPError) -> ProductCategory
    
    /// Adds a new product.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - product: The product to be added.
    /// - Returns: The newly created product.
    /// - Throws: `HHTPError` when the request or decoding fails.
    func addProduct(credentials: Credentials, product: AddProduct) async throws(HTTPError) -> Product
    
    /// Updates an existing product.
    /// - Parameter credentials: Credentials used to authenticate.
    /// - Parameter updateProduct: The product new properties.
    /// - Throws: `HTTPError`  when the request or decoding fails.
    func updateProduct(credentials: Credentials, updateProduct: ProductUpdate) async throws(HTTPError)
    
    /// Updates the image of a product.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - productId: The specific id of the product.
    ///   - image: The image data.
    /// - Returns: `ImageUpdate` with data for the new image..
    /// - Throws: `HTTPError`  when the request or decoding fails.
    func updateImage(credentials: Credentials, productId: UUID, image: Data) async throws(HTTPError) -> ImageUpdate
    
    /// Deletes a product by id.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate..
    ///   - productId: The id of the product to delete.
    func deleteProduct(credentials: Credentials, productId: UUID) async throws(HTTPError)
    
    /// Deletes all products with specified category id.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate..
    ///   - categoryId: The category id.
    func deleteProduct(credentials: Credentials, categoryId: UUID) async throws (HTTPError)
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
        let url = APIClient.shared.url
            .appending(path: "public")
            .appending(path: "product-categories")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
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
            return try jsonDecoder.decode([ProductCategory].self, from: data)
        } catch {
            throw .invalidResponse
        }
    }
    
    /// Issues a GET request to `/public/products` and decodes the response.
    func getProducts() async throws(HTTPError) -> [Product] {
        let url = APIClient.shared.url
            .appending(path: "public")
            .appending(path: "products")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
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
            return try jsonDecoder.decode([Product].self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
    
    /// Issues a GET request to `/public/products?category_id=...` and decodes the response.
    func getProductsByCategory(_ categoryId: UUID) async throws(HTTPError) -> [Product] {
        let url = APIClient.shared.url
            .appending(path: "public")
            .appending(path: "products")
            .appending(queryItems: [
                URLQueryItem(name: "category_id", value: categoryId.uuidString)
            ])
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
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
            return try jsonDecoder.decode([Product].self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
    
    /// Issues a POST request to `admin/categories`
    func addCategory(credentials: Credentials, category: AddCategory) async throws(HTTPError) -> ProductCategory {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "categories")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try jsonEncoder.encode(category)
        } catch {
            throw .bodyEncodingFailed(error)
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw .requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            throw .invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try jsonDecoder.decode(ProductCategory.self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }

    /// Issues a POST request to `/admin/products` and decodes the response.
    func addProduct(credentials: Credentials, product: AddProduct) async throws(HTTPError) -> Product {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "products")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try jsonEncoder.encode(product)
        } catch {
            throw .bodyEncodingFailed(error)
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw .requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            throw .invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try jsonDecoder.decode(Product.self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }

    /// Issues a PATCH request to `/admin/products/{id}` and checks the status code.
    func updateProduct(credentials: Credentials, updateProduct: ProductUpdate) async throws(HTTPError) {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "products")
            .appending(path: updateProduct.id.uuidString)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try jsonEncoder.encode(updateProduct)
        } catch {
            throw .bodyEncodingFailed(error)
        }
        
        let response: URLResponse
        
        do {
            (_, response) = try await URLSession.shared.data(for: request)
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
    
    /// Issues a PUT request to `/admin/products/{id}/image` and returns the new image data..
    func updateImage(credentials: Credentials, productId: UUID, image: Data) async throws(HTTPError) -> ImageUpdate {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "products")
            .appending(path: productId.uuidString)
            .appending(path: "image")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = image
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
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
            return try jsonDecoder.decode(ImageUpdate.self, from: data)
        } catch {
            throw .responseBodyDecodingFailed(error)
        }
    }
    
    /// Issues a DELETE request to `/admin/products?product_id=...` and checks the status code.
    func deleteProduct(credentials: Credentials, productId: UUID) async throws(HTTPError) {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "products")
            .appending(queryItems: [
                URLQueryItem(name: "product_id", value: productId.uuidString)
            ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let response: URLResponse
        
        do {
            (_, response) = try await URLSession.shared.data(for: request)
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
    
    /// Issues a DELETE request to `/admin/products?category_id=...` and checks the status code.
    func deleteProduct(credentials: Credentials, categoryId: UUID) async throws (HTTPError) {
        let basicCredentials = "\(credentials.username):\(credentials.password)"
        let credentialsData = Data(basicCredentials.utf8)
        let base64Credentials = credentialsData.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "products")
            .appending(queryItems: [
                URLQueryItem(name: "category_id", value: categoryId.uuidString)
            ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let response: URLResponse
        
        do {
            (_, response) = try await URLSession.shared.data(for: request)
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
}

