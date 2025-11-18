//
//  EditCategoryView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.11.25.
//

import SwiftUI


/// View to update category information.
struct EditCategoryView: View {
    @Environment(PanelViewModel.self) private var panelViewModel
    
    @Environment(ProductsViewModel.self) private var productsViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    let oldName: String
    let id: UUID
    
    @State var newName: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.oldName = name
        self.newName = name
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
                Button("Done") {
                    Task {
                        await productsViewModel.updateCategory(
                            panelViewModel: panelViewModel,
                            id: id,
                            oldName: oldName,
                            newName: newName
                        )
                    }
                    dismiss()
                }
            }
        }
    }
}
