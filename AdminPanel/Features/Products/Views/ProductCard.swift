//
//  ProductCard.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import SwiftUI

/// A card-like row presenting a product's image and details.
struct ProductCard: View {
    let product: Product
    @State private var hovering: Bool
    
    init(_ product: Product) {
        self.product = product
        self.hovering = false
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ProductImageView(product.imageUrl)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6, y: 3)
            
            ProductInformationView(product)
            Spacer()
        }
        .padding(20)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .glassEffect(in: .rect(cornerRadius: 10))
        .scaleEffect(hovering ? 1.03 : 1.0)
        .animation(.spring(duration: 0.25), value: hovering)
        .onHover { hover in
            hovering = hover
        }
    }
}
