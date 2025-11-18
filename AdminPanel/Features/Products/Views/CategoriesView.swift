//
//  CategoriesView.swift
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
    @State private var productsViewModel: ProductsViewModel
    
    @State private var isAddCategorySheetPresent: Bool
    @State private var isAddProductSheetPresent: Bool
    
    /// Creates the categories view and injects a `ProductService` and `PanelViewModel`.
    init(credentials: Credentials, productService: ProductServiceProtocol) {
        self.productsViewModel = ProductsViewModel(
            credentials: credentials,
            productService: productService
        )
        
        self.isAddCategorySheetPresent = false
        self.isAddProductSheetPresent = false
    }
    
    /// Renders a list of categories and triggers loading on appearance.
    var body: some View {
        List {
            Button("Add category", systemImage: "plus") {
                isAddCategorySheetPresent = true
            }
            
            Button("Add product", systemImage: "plus") {
                isAddProductSheetPresent = true
            }
            
            Section {
                ForEach(productsViewModel.categories) { category  in
                    NavigationLink(category.name) {
                        ProductsView(category.id)
                            .environment(productsViewModel)
                            .environment(panelViewModel)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $isAddCategorySheetPresent) {
            AddCategoryView()
                .environment(panelViewModel)
                .environment(productsViewModel)
        }
        .sheet(isPresented: $isAddProductSheetPresent) {
            AddProductView()
                .environment(productsViewModel)
        }
        .task {
            await productsViewModel.loadData(panelViewModel)
        }
    }
}

