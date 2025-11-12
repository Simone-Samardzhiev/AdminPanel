//
//  ProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import SwiftUI

/// Displays the list of product categories and navigates to the products list.
struct CategoriesView: View {
    /// Backing view model responsible for loading categories and products.
    @State var viewModel: ProductsViewModel
    
    /// Creates the categories view and injects a `ProductService` and `PanelViewModel`.
    /// - Parameter panelViewModel: The shared panel view model for loading state.
    init(_ panelViewModel: PanelViewModel) {
        self.viewModel = ProductsViewModel(
            ProductService(
                jsonEncoder: JSONEncoder(),
                jsonDecoder: JSONDecoder()),
            panelViewModel
        )
    }
    
    /// Renders a list of categories and triggers loading on appearance.
    var body: some View {
        List(viewModel.productCategories) { category in
            NavigationLink(category.name) {
                ProductsView(category.id)
                    .environment(viewModel)
            }
        }
        .task {
            await viewModel.getProductCategories()
        }
    }
}

