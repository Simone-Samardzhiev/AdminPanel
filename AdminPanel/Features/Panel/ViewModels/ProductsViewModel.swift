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
    /// The list of categories retrieved from the backend.
    var productCategories: [ProductCategory]
    /// In-memory cache of products keyed by category ID.
    @ObservationIgnored private var productsCache: [UUID: [Product]] = [:]
    /// Service used to fetch categories and products.
    @ObservationIgnored let productService: ProductServiceProtocol
    
    /// Creates a new view model with dependencies.
    /// - Parameters:
    ///   - productService: Service for API calls related to products.
    init(_ productService: ProductServiceProtocol,) {
        self.productCategories = []
        self.productService = productService
    }
    
    /// Loads product categories from the API and updates `productCategories`.
    /// - Parameter panelViewModel: View model to update loading state or occurred error.
    func getProductCategories(_ panelViewModel: PanelViewModel) async {
        panelViewModel.isLoading = true
        defer { panelViewModel.isLoading = false }
        
        do {
            self.productCategories = try await productService.getProductCategories()
        } catch {
            panelViewModel.errorMessage = error.userMessage
#if DEBUG
            print(error)
#endif
        }
    }
    
    /// Returns products for a category, using cache unless `forceRefresh` is true.
    /// - Parameters:
    ///   - categoryId: The category to load products for.
    ///   - panelViewModel: View model to update loading state or occurred error.
    ///   - forceRefresh: When true, ignores the cache and fetches from the API.
    /// - Returns: The list of products, possibly from cache, or an empty list on failure.
    func getProducts(_ categoryId: UUID, panelViewModel: PanelViewModel ,forceRefresh: Bool = false) async -> [Product] {
        panelViewModel.isLoading = true
        defer {
            panelViewModel.isLoading = false
        }
        
        if !forceRefresh, let cached = productsCache[categoryId] {
            return cached
        }
        
        do {
            let fetched = try await productService.getProducts(categoryId)
            productsCache[categoryId] = fetched
            return fetched
        } catch {
#if DEBUG
            print(error)
#endif
            
            panelViewModel.errorMessage = error.userMessage
            
            if let cached = productsCache[categoryId] {
                return cached
            }
            return []
        }
    }
}

