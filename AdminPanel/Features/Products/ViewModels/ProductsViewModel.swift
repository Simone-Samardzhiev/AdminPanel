//
//  ProductsViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

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
    
    
    
    /// Creates a new view model with dependencies.
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
    /// - Parameter panelViewModel: Panel view models to update panel state.
    func loadData(_ panelViewModel: PanelViewModel) async {
        panelViewModel.isLoading = true
        defer { panelViewModel.isLoading = false }
        
        do {
            self.categories = try await productService.getProductCategories()
            self.products = try await productService.getProducts()
        } catch {
            panelViewModel.errorMessage = error.userMessage
#if DEBUG
            print(error)
#endif
        }
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
    
    
    /// Validates products information.
    /// - Parameter product: The product to be validated.
    /// - Returns: String representing the user error message or nil of the product is valid.
    private func validateProduct(_ product: Product) -> String? {
        guard product.name.count >= 3 && product.name.count <= 100 else {
            return "Name should be between 3 and 100 characters!"
        }
        
        guard product.description.count >= 15 else {
            return "Description should be more that 15 characters!"
        }
        
        guard product.price > 0  else {
            return "Price should be more than 0!"
        }
        
        guard product.price < 999999.99 else {
            return "Price is too high!"
        }
        
        return nil
    }
    
    /// Updates an existing product.
    /// - Parameter updatedProduct: The product that should be updated
    /// - Returns: String representing the user error message or nil of the product was edited successfully.
    func updateProduct(_ updatedProduct: Product) async -> String? {
        guard let index = mapProductIdToIndex[updatedProduct.id] else {
            return "Something went wrong when updating the product!"
        }
        
        let oldProduct = products[index]
        if oldProduct == updatedProduct {
            return nil
        }
        
        
        if oldProduct.name != updatedProduct.name && productNames.contains(updatedProduct.name) {
            return "Product name already in use!"
        }
        
        if let errorMessage = validateProduct(updatedProduct) {
            return errorMessage
        }
        
        do {
            try await productService.updateProduct(
                credentials: credentials,
                updateProduct: ProductUpdate(
                    id: oldProduct.id,
                    newName: oldProduct.name == updatedProduct.name ? nil : updatedProduct.name,
                    newDescription: oldProduct.description == updatedProduct.description ? nil : updatedProduct.description,
                    newCategory: oldProduct.category == updatedProduct.category ? nil : updatedProduct.category,
                    newPrice: oldProduct.price == updatedProduct.price ? nil : updatedProduct.price
                )
            )
        } catch {
#if DEBUG
            print(error)
#endif
            return error.userMessage
        }
        
        products[index] = updatedProduct
        productNames.remove(oldProduct.name)
        productNames.insert(updatedProduct.name)
        
        return nil
    }
    
    /// Updates the image of a specific product.
    /// - Parameters:
    ///   - panelViewMode: Panel view model to update the panel state.
    ///   - productId: The product id.
    ///   - imageData: The image data.
    func updateProductImage(panelViewModel: PanelViewModel, productId: UUID, imageData: Data) async {
        panelViewModel.isLoading = true
        defer {
            panelViewModel.isLoading = false
        }
        
        let imageUpdate: ImageUpdate
        
        do {
            imageUpdate = try await productService.updateImage(
                credentials: credentials,
                productId: productId,
                image: imageData
            )
        } catch {
            #if DEBUG
            print(error)
            #endif
            panelViewModel.errorMessage = error.userMessage
            return
        }
        
        if let index = mapProductIdToIndex[productId] {
            products[index].imageUrl = imageUpdate.url
        } else {
            panelViewModel.errorMessage = "Error updating image!"
        }
    }
    
    /// Deletes a product by specific id.
    /// - Parameters:
    ///   - panelViewModel: Panel view model to update the panel state.
    ///   - productId: The product id.
    func deleteProduct(panelViewModel: PanelViewModel, productId: UUID) async {
        panelViewModel.isLoading = true
        defer {
            panelViewModel.isLoading = false
        }
        
        guard let index = mapProductIdToIndex[productId] else {
            panelViewModel.errorMessage = "Error deleting product!"
            return

        }
        
        do {
            try await productService.deleteProduct(credentials: credentials, productId: productId)
        } catch {
            panelViewModel.errorMessage = error.userMessage
            return
        }
        
        productNames.remove(products[index].name)
        products.remove(at: index)
    }
}

