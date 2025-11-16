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
    
    func updateProduct(_ newProduct: Product) async -> String? {
        guard let index = mapProductIdToIndex[newProduct.id] else {
            return "Something went wrong when updating the product!"
        }
        
        let oldProduct = products[index]
        if oldProduct == newProduct {
            return nil
        }
        
        
        if oldProduct.name != newProduct.name && productNames.contains(newProduct.name) {
            return "Product name already in use!"
        }
        
        if let errorMessage = validateProduct(newProduct) {
            return errorMessage
        }
        
        do {
            try await productService.updateProduct(
                credentials: credentials,
                updateProduct: ProductUpdate(
                    id: oldProduct.id,
                    newName: oldProduct.name == newProduct.name ? nil : newProduct.name,
                    newDescription: oldProduct.description == newProduct.description ? nil : newProduct.description,
                    newCategory: oldProduct.category == newProduct.category ? nil : newProduct.category,
                    newPrice: oldProduct.price == newProduct.price ? nil : newProduct.price
                )
            )
        } catch {
#if DEBUG
            print(error)
#endif
            return error.userMessage
        }
        
        products[index] = newProduct
        productNames.remove(oldProduct.name)
        productNames.insert(newProduct.name)
        
        return nil
    }
}

