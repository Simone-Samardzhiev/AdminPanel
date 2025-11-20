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
                            activeSheet = .editCategory(categoryId: category.id, categoryName: category.name)
                        }
                        Button("Delete", systemImage: "trash") {
                            activeSheet = .deleteProduct(categoryId: category.id, categoryName: category.name)
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
                
            case .editCategory(let categoryId, let categoryName):
                EditCategoryView(id: categoryId, name: categoryName)
                    .environment(panelViewModel)
                    .environment(productsViewModel)
                
            case .deleteProduct(let categoryId, let categoryName ):
                DeleteCategoryView(categoryId: categoryId, categoryName: categoryName)
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
            case .editCategory(_, _): return "editCategory"
            case .deleteProduct(_, _): return "deleteProduct"
            }
        }
        case addProduct
        case addCategory
        case editCategory(categoryId: UUID, categoryName: String)
        case deleteProduct(categoryId: UUID, categoryName: String)
    }
}

