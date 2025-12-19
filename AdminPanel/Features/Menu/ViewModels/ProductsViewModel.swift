//
//  ProductsViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation
import os

/// View model responsible for loading product categories and products,
/// caching results per category, and coordinating loading state with `PanelViewModel`.
@Observable
@MainActor
final class ProductsViewModel {
    @ObservationIgnored private let credentials: Credentials
    
    /// Service used to fetch categories and products.
    @ObservationIgnored private let productService: ProductServiceProtocol
    
    /// The list of categories retrieved from the backend.
    var categories: [ProductCategory]
    
    /// Set holding category names for easier validation of duplicate names.
    @ObservationIgnored private var categoryNames: Set<String>
    
    /// The list of products retrieved from the backend.
    var products: [Product]
    
    /// Set holding product names for easier validation of duplicate names.
    @ObservationIgnored private var productNames: Set<String>
    
    /// Map holding product id to its corresponding index in the array for easier and efficient updates.
    @ObservationIgnored private var mapProductIdToIndex: [UUID: Int]
    
    /// Default initializer.
    /// - Parameters:
    ///   - credentials: Valid credentials the user used to authenticate.
    ///   - productService: Service for API calls related to products.
    init(credentials: Credentials, productService: ProductServiceProtocol) {
        self.credentials = credentials
        self.productService = productService
        
        self.categories = []
        self.categoryNames = []
        
        self.products = []
        self.productNames = []
        self.mapProductIdToIndex = [:]
    }
    
    /// Fetches all product categories and products.
    func loadData() async throws(HTTPError) {
        self.categories = try await productService.getProductCategories()
        self.products = try await productService.getProducts()
        loadHelperData()
    }
    
    /// Loads helper data to validate or access products faster.
    private func loadHelperData() {
        categoryNames.reserveCapacity(categories.count)
        
        for category in categories {
            categoryNames.insert(category.name)
        }
        
        productNames.reserveCapacity(products.count)
        mapProductIdToIndex.reserveCapacity(products.count)
        
        for (index, product) in products.enumerated() {
            productNames.insert(product.name)
            mapProductIdToIndex[product.id] = index
        }
    }
    
    /// Filters products by category id.
    /// - Parameter categoryId: Category id used for filtering.
    /// - Returns: Filtered products.
    func getProductsByCategory(_ categoryId: UUID) -> [Product] {
        return products.filter { product in
            product.category == categoryId
        }
    }
    
    /// Adds a new category.
    /// - Parameter categoryName: The name of the new category.
    /// - Throws: `CategoryError`
    func addCategory(categoryName: String) async throws(CategoryError)  {
        guard categoryName.count >= 4 && categoryName.count <= 100 else {
            throw.invalidName
        }
        
        guard !categoryNames.contains(categoryName) else {
            throw .duplicateName
        }
        
        let createdCategory: ProductCategory
        
        do {
            createdCategory = try await productService.addCategory(
                credentials: credentials,
                category: AddProductCategory(name: categoryName)
            )
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error adding category \(error.localizedDescription)")
            throw .network(error)
        }
        
        categories.append(createdCategory)
        categoryNames.insert(createdCategory.name)
    }
    
    /// Updates a category.
    /// - Parameters:
    ///   - id: The id of the category.
    ///   - oldName: The old name of the category.
    ///   - newName: The new name of the category.
    func updateCategory(id: UUID, oldName: String, newName: String) async throws(CategoryError) {
        guard oldName != newName else {
            return
        }
        
        guard newName.count >= 4 && newName.count <= 100 else {
            throw .invalidName
        }
        
        guard !categoryNames.contains(newName) else {
            throw .duplicateName
        }
        
        do {
            try await productService.updateCategory(
                credentials: credentials,
                categoryUpdate: .init(id: id, name: newName)
            )
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error updating category \(error.localizedDescription)")
            throw .network(error)
        }
        
        categoryNames.remove(oldName)
        categories.removeAll(where: {$0.name == oldName})
        
        categoryNames.insert(newName)
        categories.append(.init(id: id, name: newName))
    }
    
    func deleteCategory(categoryId: UUID, categoryName: String) async throws(CategoryError) {
        do {
            try await productService.deleteProductByCategoryId(credentials: credentials, categoryId: categoryId)
            try await productService.deleteCategory(credentials: credentials, categoryId: categoryId)
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error deleting category \(error.localizedDescription)")
            throw .network(error)
        }
        
        categoryNames.remove(categoryName)
        categories.removeAll { $0.id == categoryId }
        
        products.removeAll { $0.category == categoryId }
        productNames = Set(products.map { $0.name })
        mapProductIdToIndex = Dictionary(uniqueKeysWithValues: products.enumerated().map { ($0.element.id, $0.offset) })
    }
    
    /// Adds a new product.
    /// - Parameters:
    ///   - product: The product to be added.
    func addProduct(_ product: AddProduct) async throws(ProductError) {
        try product.validate()
        
        let createdProduct: Product
        do {
            createdProduct = try await productService.addProduct(credentials: credentials, product: product)
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error adding product \(error.localizedDescription)")
            throw .network(error)
        }
        
        productNames.insert(createdProduct.name)
        mapProductIdToIndex[createdProduct.id] = products.count
        products.append(createdProduct)
    }
    
    /// Updates an existing product.
    /// - Parameter updatedProduct: The product that should be updated
    /// - Returns: String representing the user error message or nil of the product was edited successfully.
    func updateProduct(_ updatedProduct: Product) async throws(ProductError) {
        guard let index = mapProductIdToIndex[updatedProduct.id] else {
            LoggerConfig.shared.logCore(level: .error, "Error mapping product id to index(id = \(updatedProduct.id.uuidString))")
            throw .productNotFound
        }
        
        let oldProduct = products[index]
        if oldProduct == updatedProduct {
            return
        }
        
        
        if oldProduct.name != updatedProduct.name && productNames.contains(updatedProduct.name) {
            throw .duplicateName
        }
        
        do {
            try await productService.updateProduct(
                credentials: credentials,
                productUpdate: ProductUpdate(
                    id: oldProduct.id,
                    newName: oldProduct.name == updatedProduct.name ? nil : updatedProduct.name,
                    newDescription: oldProduct.description == updatedProduct.description ? nil : updatedProduct.description,
                    newCategory: oldProduct.category == updatedProduct.category ? nil : updatedProduct.category,
                    newPrice: oldProduct.price == updatedProduct.price ? nil : updatedProduct.price
                )
            )
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error updating product \(error.localizedDescription)")
            throw .network(error)
        }
        
        products[index] = updatedProduct
        productNames.remove(oldProduct.name)
        productNames.insert(updatedProduct.name)
    }
    
    /// Updates the image of a specific product.
    /// - Parameters:
    ///   - productId: The product id.
    ///   - imageData: The image data.
    func updateProductImage(productId: UUID, imageData: Data) async throws(ProductError) {
        let imageUpdate: ImageUpdate
        do {
            imageUpdate = try await productService.updateImage(
                    credentials: credentials,
                    productId: productId,
                    image: imageData
                )
        } catch {
            throw .network(error)
        }

        if let index = mapProductIdToIndex[productId] {
            products[index].imageUrl = imageUpdate.url
        } else {
            throw .productNotFound
        }
    }
    
    /// Deletes a product by specific id.
    /// - Parameters:
    ///   - productId: The product id.
    func deleteProduct(productId: UUID) async throws(ProductError) {
        guard let index = mapProductIdToIndex[productId] else {
            throw .productNotFound
        }
        
        do {
            try await productService.deleteProductById(credentials: credentials, productId: productId)
        } catch {
            throw .network(error)
        }
        
        productNames.remove(products[index].name)
        products.remove(at: index)
        mapProductIdToIndex.removeValue(forKey: productId)
    }
}
