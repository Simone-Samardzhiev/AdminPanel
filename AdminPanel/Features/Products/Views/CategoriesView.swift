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
    
    @State private var activeSheet: ActiveSheet?
    
    /// Creates the categories view and injects a `ProductService` and `PanelViewModel`.
    init(credentials: Credentials, productService: ProductServiceProtocol) {
        self.productsViewModel = ProductsViewModel(
            credentials: credentials,
            productService: productService
        )
    
        self.activeSheet = nil
    }
    
    /// Renders a list of categories and triggers loading on appearance.
    var body: some View {
        List {
            Button("Add category", systemImage: "plus") {
                activeSheet = .addCategory
            }
            
            Button("Add product", systemImage: "plus") {
                activeSheet = .addProduct
            }
            
            Section {
                ForEach(productsViewModel.categories) { category  in
                    NavigationLink(category.name) {
                        ProductsView(category.id)
                            .environment(productsViewModel)
                            .environment(panelViewModel)
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .editCategory(id: category.id, name: category.name)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addCategory:
                AddCategoryView()
                    .environment(panelViewModel)
                    .environment(productsViewModel)
            case .addProduct:
                AddProductView()
                    .environment(productsViewModel)
            case .editCategory(let id, let name):
                EditCategoryView(id: id, name: name)
                    .environment(panelViewModel)
                    .environment(productsViewModel)
            }
        }
        .task {
            await productsViewModel.loadData(panelViewModel)
        }
    }
}

extension CategoriesView {
    private enum ActiveSheet: Identifiable {
        var id: String {
            switch self {
            case .addProduct: return "addProduct"
            case .addCategory: return "addCategory"
            case .editCategory(let id, let name): return "\(id.uuidString)-\(name)"
            }
        }
        case addProduct
        case addCategory
        case editCategory(id: UUID, name: String)
    }
}

