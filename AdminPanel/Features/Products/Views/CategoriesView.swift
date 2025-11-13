//
//  ProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import SwiftUI

/// Displays the list of product categories and navigates to the products list.
struct CategoriesView: View {
    /// Injected view to update state of the panel.
    @Environment(PanelViewModel.self) private var panelViewModel
    
    /// Backing view model responsible for loading categories and products.
    @State var viewModel: ProductsViewModel
    
    /// Creates the categories view and injects a `ProductService` and `PanelViewModel`.
    init(_ productService: ProductServiceProtocol) {
        self.viewModel = ProductsViewModel(productService)
    }
    
    /// Renders a list of categories and triggers loading on appearance.
    var body: some View {
        List(viewModel.productCategories) { category in
            NavigationLink(category.name) {
                ProductsView(category.id)
                    .environment(viewModel)
                    .environment(panelViewModel)
            }
        }
        .task {
            await viewModel.getProductCategories(panelViewModel)
        }
    }
}

