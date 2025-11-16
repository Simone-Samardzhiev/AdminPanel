//
//  ProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 11.11.25.
//

import SwiftUI

/// Displays a scrollable list of products for a given category.
struct ProductsView: View {
    /// Injected view to update state of the panel.
    @Environment(PanelViewModel.self) private var panelViewModel
    
    /// Injected view model used to fetch and cache products.
    @Environment(ProductsViewModel.self) private var productViewModel
    
    /// The identifier of the category to display.
    private let productCategoryId: UUID
    
    @State private var productToEdit: Product?
    
    /// Creates the view for a specific product category.
    /// - Parameter productCategoryId: The identifier of the category to display.
    init(_ productCategoryId: UUID) {
        self.productCategoryId = productCategoryId
        self.productToEdit = nil
    }
    
    /// Renders product cards and triggers loading when the category changes.
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(productViewModel.getProductsByCategory(productCategoryId)) { product in
                    ProductCard(product)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                productToEdit = product
                            }
                            Button("Delete", systemImage: "trash") {
                                
                            }
                        }
                }
            }
            .padding(.vertical, 20)
            .sheet(item: $productToEdit) {product in
                EditProductView(product)
            }
        }
        .frame(minWidth: 500)
    }
}
