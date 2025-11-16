//
//  ProductImageView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 16.11.25.
//

import SwiftUI

/// Displays a remote image when available, otherwise a placeholder.
struct ProductImageView: View {
    let stringURL: String?
    
    init(_ stringURL: String?) {
        self.stringURL = stringURL
    }
    
    var body: some View {
        if let stringURL = stringURL, let url = URL(string: stringURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        } else {
            ZStack {
                Color.gray.opacity(0.2)
                Text("No image")
                    .foregroundColor(.secondary)
            }
        }
    }
}
