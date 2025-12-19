//
//  OrderedProductsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import SwiftUI

import SwiftUI

struct OrderedProductsView: View {
    @Environment(OrdersViewModel.self) private var ordersViewModel
    @Environment(ProductsViewModel.self) private var productsViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(OrderedProduct.Status.allCases, id: \.self) { status in
                    StatusColumn(
                        status: status,
                        products: ordersViewModel.orderedProductsByStatus(status)
                    )
                }
            }
            .padding()
        }
    }
}

extension OrderedProductsView {
    private struct StatusColumn: View {
        let status: OrderedProduct.Status
        let products: [OrderedProduct]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(status.rawValue.capitalized)
                    .font(.headline)
                    .padding(.bottom, 4)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(products) { product in
                            OrderedProductCard(product)
                        }
                    }
                }
            }
            .frame(width: 260)
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glassEffect(in: .rect(cornerRadius: 16))
        }
    }

    
    private struct OrderedProductCard: View {
        @Environment(OrdersViewModel.self) private var ordersViewModel
        @Environment(ProductsViewModel.self) private var productsViewModel

        let orderedProduct: OrderedProduct
        
        init(_ orderedProduct: OrderedProduct) {
            self.orderedProduct = orderedProduct
        }

        var body: some View {
            Group {
                if let product = product,
                   let session = session {
                    content(product: product, session: session)
                } else {
                    missingDataView
                }
            }
        }


        private func content(product: Product, session: OrderSession) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.headline)

                HStack(spacing: 6) {
                    Image(systemName: "table.furniture")
                    Text("Table \(session.tableNumber)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            .glassEffect(in: .rect(cornerRadius: 12))
        }

        private var missingDataView: some View {
            Text("Product unavailable")
                .font(.caption)
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .glassEffect(in: .rect(cornerRadius: 12))
        }

        private var product: Product? {
            productsViewModel.getProductById(orderedProduct.productId)
        }

        private var session: OrderSession? {
            ordersViewModel.getOrderSessionById(orderedProduct.orderSessionId)
        }
    }

    
}
