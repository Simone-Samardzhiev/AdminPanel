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
    
    @Environment(PanelViewModel.self) private var panelViewModel
    
    @Environment(ProductsViewModel.self) private var productsViewModel
    
    private let productCategoryId: UUID
    
    @State private var productToEdit: Product? = nil
    
    @State private var isFileImporterPresent: Bool = false
    
    @State private var productIdImageToUpdate: UUID? = nil
    
    init(_ productCategoryId: UUID) {
        self.productCategoryId = productCategoryId
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(productsViewModel.getProductsByCategory(productCategoryId)) { product in
                        ProductCard(product)
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                            .contextMenu {
                                Button("Edit", systemImage: "pencil") {
                                    productToEdit = product
                                }
                                Button("Change image", systemImage: "photo") {
                                    productIdImageToUpdate = product.id
                                    isFileImporterPresent = true
                                }
                                Button("Delete product", systemImage: "trash") {
                                    Task {
                                        await productsViewModel.deleteProduct(
                                            panelViewModel: panelViewModel,
                                            productId: product.id
                                        )
                                    }
                                }
                            }
                    }
                }
                .padding(.vertical, 20)
                .sheet(item: $productToEdit) {product in
                    EditProductView(product)
                }
                .fileImporter(
                    isPresented: $isFileImporterPresent,
                    allowedContentTypes: [.png, .jpeg]) { result in
                        if let id = productIdImageToUpdate {
                            onCompletionImportFile(
                                productId: id,
                                result: result
                            )
                        }
                    }
            }
        }
        .frame(minWidth: 500)
    }
    
    private func onCompletionImportFile(productId: UUID, result: Result<URL, any Error>) {
        let data: Data
        
        do {
            data = try .init(contentsOf: result.get())
        } catch {
            panelViewModel.errorMessage = "Failed to import file."
            return
        }
        
        Task {
            await productsViewModel.updateProductImage(
                panelViewModel: panelViewModel,
                productId: productId,
                imageData: data
            )
        }
    }
}

extension ProductsView {
    /// Shows the product's textual information allowing users to edit it.
    struct EditProductView: View {
        @Environment(\.dismiss) private var dismiss
        
        @Environment(ProductsViewModel.self) var productsViewModel
        
        @State private var product: Product
        
        @State private var errorMessage: String?
        
        init(_ product: Product) {
            self.product = product
            self.errorMessage = nil
        }
        
        private var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit Product")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                nameEdit
                descriptionEdit
                priceEdit
                categoryPicker
                
                if let errorMessage = self.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                }
            }
            .padding(.all, 32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            errorMessage = await productsViewModel.updateProduct(product)
                            if errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        
        /// Text field to edit the name.
        private var nameEdit: some View {
            LabeledContent("Name") {
                TextField("Name", text: $product.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
            }
        }
        
        /// Text editor to edit the description.
        private var descriptionEdit: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $product.description)
                    .font(.body)
                    .frame(minHeight: 140)
                    .padding(12)
                    .textEditorStyle(.plain)
                
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.quaternary, lineWidth: 1)
                    )
            }
        }
        
        /// Text field to edit the price.
        private var priceEdit: some View {
            LabeledContent("Price") {
                TextField("Price", value: $product.price, format: .currency(code: currencyCode))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }

        }
        
        /// Picker to edit the product category.
        private var categoryPicker: some View {
            Picker("Category", selection: $product.category) {
                ForEach(productsViewModel.categories) {category in
                    Text(category.name)
                        .tag(category.id)
                }
            }
        }
    }
    
    /// A card-like row presenting a product's image and details.
    private struct ProductCard: View {
        private let product: Product
        @State private var hovering: Bool
        
        init(_ product: Product) {
            self.product = product
            self.hovering = false
        }
        
        var body: some View {
            HStack(spacing: 16) {
                ProductImageView(product.imageUrl)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 6, y: 3)
                
                ProductInformationView(product)
                Spacer()
            }
            .padding(20)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .glassEffect(in: .rect(cornerRadius: 10))
            .scaleEffect(hovering ? 1.03 : 1.0)
            .animation(.spring(duration: 0.25), value: hovering)
            .onHover { hover in
                hovering = hover
            }
        }
    }
    
    /// Displays a remote image when available, otherwise a placeholder.
    private struct ProductImageView: View {
        private let stringURL: String?
        
        init(_ stringURL: String?) {
            self.stringURL = stringURL
        }
        
        var body: some View {
            if let stringURL = stringURL, let url = URL(string: stringURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                ZStack {
                    Color.gray.opacity(0.2)
                    Text("No image")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    /// Shows the product's textual information such as name, description, and price.
    private struct ProductInformationView: View {
        private let product: Product
        
        init(_ product: Product) {
            self.product = product
        }
        
        private var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Text("Price: \(product.price.formatted(.currency(code: currencyCode)))")
                    .font(.subheadline.bold())
                    .foregroundStyle(.tint)
                    .padding(.top, 4)
                
                Spacer()
            }
        }
    }
}

