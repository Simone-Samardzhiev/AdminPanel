//
//  EditProductView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import SwiftUI

/// Shows the product's textual information allowing users to edit it.
struct EditProductView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(ProductsViewModel.self) var productViewModel
    
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
                        errorMessage = await productViewModel.updateProduct(product)
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
            ForEach(productViewModel.categories) {category in
                Text(category.name)
                    .tag(category.id)
            }
        }
    }
}
