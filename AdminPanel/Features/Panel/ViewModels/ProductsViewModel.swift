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
    /// Panel view model used to toggle the global loading indicator.
    @ObservationIgnored private let panelViewModel: PanelViewModel
    
    /// Creates a new view model with dependencies.
    /// - Parameters:
    ///   - productService: Service for API calls related to products.
    ///   - panelViewModel: View model controlling global loading state.
    init(_ productService: ProductServiceProtocol, _ panelViewModel: PanelViewModel) {
        self.productCategories = []
        self.productService = productService
        self.panelViewModel = panelViewModel
    }
    
    /// Loads product categories from the API and updates `productCategories`.
    func getProductCategories() async {
        panelViewModel.isLoading = true
        defer {
            panelViewModel.isLoading = false
        }
        
        do {
            self.productCategories = try await productService.getProductCategories()
        } catch {
            
        }
    }
    
    /// Returns products for a category, using cache unless `forceRefresh` is true.
    /// - Parameters:
    ///   - categoryId: The category to load products for.
    ///   - forceRefresh: When true, ignores the cache and fetches from the API.
    /// - Returns: The list of products, possibly from cache, or an empty list on failure.
    func getProducts(_ categoryId: UUID, forceRefresh: Bool = false) async -> [Product] {
        if !forceRefresh, let cached = productsCache[categoryId] {
            return cached
        }
        
        panelViewModel.isLoading = true
        defer {
            panelViewModel.isLoading = false
        }
        
        do {
            let fetched = try await productService.getProducts(categoryId)
            productsCache[categoryId] = fetched
            return fetched
        } catch {
            if let cached = productsCache[categoryId] {
                return cached
            }
            return []
        }
    }
}

