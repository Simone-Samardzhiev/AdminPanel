//
//  OrderedProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import SwiftUI

struct OrderedProductsView: View {
    @Environment(OrdersViewModel.self) var ordersViewModel
    
    var body: some View {
        HStack {
            List {
                Section("Pending") {
                    ForEach(ordersViewModel.orderedProductsByStatus(status: .pending)) { product in
                        Text(product.id.uuidString)
                    }
                }
            }

            List {
                Section("Preparing") {
                    ForEach(ordersViewModel.orderedProductsByStatus(status: .preparing)) { product in
                        Text(product.id.uuidString)
                    }
                }
            }

            List {
                Section("Done") {
                    ForEach(ordersViewModel.orderedProductsByStatus(status: .done)) { product in
                        Text(product.id.uuidString)
                    }
                }
            }
        }
    }
}
