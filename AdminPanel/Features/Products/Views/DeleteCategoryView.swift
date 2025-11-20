//
//  DeleteCategoryView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 18.11.25.
//

import SwiftUI


struct DeleteCategoryView: View {
    @Environment(PanelViewModel.self) private var panelViewModel
    
    @Environment(ProductsViewModel.self) private var productsViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    
    private let categoryId: UUID
    private let categoryName: String
    
    init(categoryId: UUID, categoryName: String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
    }
    
    var body: some View {
        Text("Warning: This will delete all products of the this category!")
            .font(.title2.bold())
            .foregroundStyle(.red)
            .padding(.all, 32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Delete") {
                        Task {
                            await productsViewModel.deleteCategory(
                                panelViewModel: panelViewModel,
                                categoryId: categoryId,
                                categoryName: categoryName
                            )
                            
                            dismiss()
                        }
                    }
                }
            }
    }
}
