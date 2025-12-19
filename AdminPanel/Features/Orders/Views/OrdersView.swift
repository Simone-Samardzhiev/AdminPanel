//
//  OrdersView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import SwiftUI

/// View displaying order sessions and order products.
struct OrdersView: View {
    @Environment(PanelViewModel.self) var panelViewModel
    
    @Environment(ProductsViewModel.self) var productsViewModel
    
    @Environment(OrdersViewModel.self) var ordersViewModel
    
    var body: some View {
        List {
            Button("Add session", systemImage: "plus") {
                Task {
                    do {
                        panelViewModel.isLoading = true
                        defer { panelViewModel.isLoading = false }
                        
                        try await ordersViewModel.createOrderSession()
                    } catch let error as UserRepresentableError {
                        panelViewModel.errorMessage = error.userMessage
                    }
                }
            }
            
            Section {
                NavigationLink("Order sessions") {
                    OrderSessionsView()
                        .environment(panelViewModel)
                        .environment(ordersViewModel)
                }
                
                NavigationLink("Ordered products") {
                    OrderedProductsView()
                        .environment(panelViewModel)
                        .environment(productsViewModel)
                        .environment(ordersViewModel)
                }
            }
        }
        .listStyle(.sidebar)
    }
}
