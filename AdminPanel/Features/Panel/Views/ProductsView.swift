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
    @Environment(ProductsViewModel.self) private var viewModel
    
    /// The identifier of the category to display.
    private let productCategoryId: UUID
    
    // Array holding all products.
    @State private var products: [Product]
    
    /// Creates the view for a specific product category.
    /// - Parameter productCategoryId: The identifier of the category to display.
    init(_ productCategoryId: UUID) {
        self.products = []
        self.productCategoryId = productCategoryId
    }
    
    /// Renders product cards and triggers loading when the category changes.
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(products) { product in
                    ProductCard(product)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }
            }
            .padding(.vertical, 20)
        }
        .frame(minWidth: 500)
        .task(id: productCategoryId) {
            products = await viewModel.getProducts(productCategoryId, panelViewModel: panelViewModel)
        }
    }
}

private extension ProductsView {
    /// A card-like row presenting a product's image and details.
    struct ProductCard: View {
        let product: Product
        @State private var hovering: Bool
        
        init(_ product: Product) {
            self.product = product
            self.hovering = false
        }
        
        var body: some View {
            HStack(spacing: 16) {
                ImageView(product.imageUrl)
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
    struct ImageView: View {
        let stringURL: String?
        
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
    struct ProductInformationView: View {
        let product: Product
        
        init(_ product: Product) {
            self.product = product
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
                
                Text("Price: \(product.price.formatted())")
                    .font(.subheadline.bold())
                    .foregroundStyle(.tint)
                    .padding(.top, 4)
                
                Spacer()
            }
        }
    }
}

