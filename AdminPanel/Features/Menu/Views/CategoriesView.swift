//
//  CategoriesView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import SwiftUI

/// Displays all categories and manages navigation to product lists.
struct CategoriesView: View {
    @Environment(PanelViewModel.self) private var panelViewModel
    
    @Environment(ProductsViewModel.self) var productsViewModel
    
    @State private var activeSheet: ActiveSheet?
    
    init() {
        self.activeSheet = nil
    }
    
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
    }
}

extension CategoriesView {
    /// Identifies which sheet is currently active.
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
    
    /// Sheet for creating a new category.
    private struct AddCategoryView: View {
        @Environment(ProductsViewModel.self) private var productsViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        /// The name of the category.
        @State private var name: String
        
        /// Variable representing whether adding is in progress.
        @State private var isLoading: Bool
        
        /// Error message to be displayed.
        @State private var errorMessage: String?
        
        init() {
            self.name = ""
            self.isLoading = false
            self.errorMessage = nil
        }
        
        var body: some View {
            VStack(spacing: 24) {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                }
            }
            .padding(.all, 32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    addButton
                }
            }
        }
        
        /// Button for adding a category.
        private var addButton: some View {
            Button {
                Task {
                    do {
                        isLoading = true
                        try await productsViewModel.addCategory(categoryName: name)
                        dismiss()
                    } catch let error as UserRepresentableError {
                        errorMessage = error.userMessage
                        isLoading = false
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Add")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
            .disabled(isLoading)
        }
    }
    
    /// Sheet for editing an existing category.
    private struct EditCategoryView: View {
        @Environment(PanelViewModel.self) private var panelViewModel
        
        @Environment(ProductsViewModel.self) private var productsViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        let oldName: String
        
        let id: UUID
        
        @State private var isLoading: Bool
        
        @State var newName: String
        
        init(id: UUID, name: String) {
            self.id = id
            self.oldName = name
            self.newName = name
            self.isLoading = false
        }
        
        var body: some View {
            LabeledContent("Name") {
                TextField("Name", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
            }
            .padding(.all, 32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    doneButton
                }
            }
        }
        
        /// Button to finish updating a category.
        private var doneButton: some View {
            Button {
                Task {
                    do {
                        isLoading = true
                        try await productsViewModel.updateCategory(id: id, oldName: oldName, newName: newName)
                        dismiss()
                    } catch let error as UserRepresentableError {
                        panelViewModel.errorMessage = error.userMessage
                        isLoading = false
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
            .disabled(isLoading)
        }
    }
    
    /// Sheet for deleting a product category
    private struct DeleteCategoryView: View {
        @Environment(PanelViewModel.self) private var panelViewModel
        
        @Environment(ProductsViewModel.self) private var productsViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        /// The id of the category that will be updated.
        private let categoryId: UUID
        
        /// The category name that will be updated.
        private let categoryName: String
        
        /// Variable representing whether deleting is in progress.
        @State private var isLoading: Bool
        
        init(categoryId: UUID, categoryName: String) {
            self.categoryId = categoryId
            self.categoryName = categoryName
            self.isLoading = false
        }
        
        var body: some View {
            Text("Are you sure you want to delete \(categoryName). This will delete all products in this category!")
                .font(.title2.bold())
                .padding(.all, 32)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        deleteButton
                    }
                }
        }
        
        private var deleteButton: some View {
            Button {
                Task {
                    do {
                        isLoading = true
                        try await productsViewModel.deleteCategory(
                            categoryId: categoryId,
                            categoryName: categoryName
                        )
                        dismiss()
                    } catch let error as UserRepresentableError {
                        panelViewModel.errorMessage = error.userMessage
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
            .disabled(isLoading)
        }
    }
    
    /// Sheet for creating a new product.
    private struct AddProductView: View {
        @Environment(\.dismiss) private var dismiss
        
        @Environment(ProductsViewModel.self) private var productsViewModel
        
        /// Variable representing if adding products is in progress.
        @State private var isLoading: Bool
        
        /// Error message to be displayed.
        @State private var errorMessage: String?
        
        /// Empty product draft to create a product.
        @State private var productDraft: ProductDraft
        
        init() {
            self.isLoading = false
            self.errorMessage = nil
            self.productDraft = .init()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Add Product")
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
                    addButton
                }
            }
        }
        
        private var currencyCode: String {
            Locale.current.currency?.identifier ?? "USD"
        }
        
        /// Text field to edit the name.
        private var nameEdit: some View {
            LabeledContent("Name") {
                TextField("Name", text: $productDraft.name)
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
                
                TextEditor(text: $productDraft.description)
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
                TextField("Price", value: $productDraft.price, format: .currency(code: currencyCode))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }
            
        }
        
        /// Picker to edit the product category.
        private var categoryPicker: some View {
            Picker("Category", selection: $productDraft.category) {
                ForEach(productsViewModel.categories) {category in
                    Text(category.name)
                        .tag(category.id)
                }
            }
        }
        
        /// Button used for adding a product.
        private var addButton: some View {
            Button {
                Task {
                    if let category = productDraft.category {
                        do {
                            isLoading = true
                            try await productsViewModel.addProduct(
                                .init(
                                    name: productDraft.name,
                                    description: productDraft.description,
                                    category: category,
                                    price: productDraft.price
                                )
                            )
                            dismiss()
                        } catch let error as UserRepresentableError {
                            errorMessage = error.userMessage
                            isLoading = false
                        }
                        
                    } else {
                        errorMessage = "Please provide a category!"
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
            .disabled(isLoading)
        }
        
        private struct ProductDraft {
            var name: String
            var description: String
            var price: Decimal
            var category: UUID?
            
            init() {
                self.name = ""
                self.description = ""
                self.price = 0
                self.category = nil
            }
        }
    }
}
