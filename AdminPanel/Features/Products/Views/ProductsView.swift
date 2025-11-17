//
//  ProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 11.11.25.
//

import SwiftUI
import UniformTypeIdentifiers

/// Displays a scrollable list of products for a given category.
struct ProductsView: View {
    /// Injected view to update state of the panel.
    @Environment(PanelViewModel.self) private var panelViewModel
    
    /// Injected view model used to fetch and cache products.
    @Environment(ProductsViewModel.self) private var productViewModel
    
    /// The identifier of the category to display.
    private let productCategoryId: UUID
    
    @State private var productToEdit: Product?
    
    @State private var productIdImageToUpdate: UUID?
    
    /// Creates the view for a specific product category.
    /// - Parameter productCategoryId: The identifier of the category to display.
    init(_ productCategoryId: UUID) {
        self.productCategoryId = productCategoryId
        self.productToEdit = nil
        self.productIdImageToUpdate = nil
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
                            Button("Change image", systemImage: "photo") {
                                productIdImageToUpdate = product.id
                            }
                        }
                }
            }
            .padding(.vertical, 20)
            .sheet(item: $productToEdit) {product in
                EditProductView(product)
            }
            .fileImporter(
                isPresented: .constant(productIdImageToUpdate != nil),
                allowedContentTypes: [.png, .jpeg]) { result in
                    if let id = productIdImageToUpdate {
                        onCompletionImportFile(
                            productId: id,
                            result: result
                        )
                    }
                }
        }
        .frame(minWidth: 500)
    }
    
    /// Function that handles file import.
    /// - Parameters:
    ///   - productId: The product id to which the file was imported.
    ///   - result: The result of the file import.
    private func onCompletionImportFile(productId: UUID, result: Result<URL, any Error>) {
        let data: Data
        
        do {
            data = try .init(contentsOf: result.get())
        } catch {
            panelViewModel.errorMessage = "Failed to import file."
            return
        }
        
        Task {
            await productViewModel.updateProductImage(
                panelViewMode: panelViewModel,
                productId: productId,
                imageData: data
            )
        }
    }
}
