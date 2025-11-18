//
//  AddProductView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 17.11.25.
//

import SwiftUI

/// View for adding a new product,
struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(PanelViewModel.self) var panelViewModel
    
    @Environment(ProductsViewModel.self) var productsViewModel
    
    /// Error message to be displayed.
    @State var errorMessage: String?
    
    /// Empty product.
    @State var product: AddProduct
    
    init() {
        self.errorMessage = nil
        self.product = .init()
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
                Button("Add") {
                    Task {
                        errorMessage = await productsViewModel.addProduct(product)
                        if errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
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
