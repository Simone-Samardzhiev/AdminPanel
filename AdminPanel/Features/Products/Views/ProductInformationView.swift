//
//  ProductInformationView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import SwiftUI

/// Shows the product's textual information such as name, description, and price.
struct ProductInformationView: View {
    private let product: Product
    
    init(_ product: Product) {
        self.product = product
    }
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Text("Price: \(product.price.formatted(.currency(code: currencyCode)))")
                .font(.subheadline.bold())
                .foregroundStyle(.tint)
                .padding(.top, 4)
            
            Spacer()
        }
    }
}
