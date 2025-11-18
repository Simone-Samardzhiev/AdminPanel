//
//  AddCategoryView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.11.25.
//

import SwiftUI


struct AddCategoryView: View {
    
    @Environment(PanelViewModel.self) var panelViewModel
    @Environment(ProductsViewModel.self) var productsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    
    init() {
        self.name = ""
    }
    
    var body: some View {
        LabeledContent("Name") {
            TextField("Name", text: $name)
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
                Button("Add") {
                    Task {
                        await productsViewModel.addCategory(
                            panelViewModel: panelViewModel, categoryName: name)
                    }
                    dismiss()
                }
            }
        }
    }
}
