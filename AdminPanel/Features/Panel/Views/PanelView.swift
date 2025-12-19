//
//  PanelView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import SwiftUI
import os

/// The main container view for the admin panel UI.
///
/// Displays a split view with a navigation list on the leading side and content
////detail placeholders. Shows a loading indicator in the toolbar when `isLoading` is true.
struct PanelView: View {
    /// Backing view model that exposes shared UI-state like loading.
    @State private var panelViewModel: PanelViewModel
    
    @State private var productViewModel: ProductsViewModel
    
    @State private var ordersViewModel: OrdersViewModel
    
    private let credentials: Credentials
    
    /// Creates the panel view with a fresh `PanelViewModel` instance.
    init(_ credentials: Credentials) {
        self.panelViewModel = .init()
    
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        
        self.productViewModel = .init(
            credentials: credentials,
            productService: ProductService(
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            )
        )
        
        self.ordersViewModel = .init(
            credentials: credentials,
            orderService: OrderService(
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder),
            qrCodeGenerator: QRCodeGenerator()
        )
        
        self.credentials = credentials
    }
    
    
    /// Renders the split-view layout and toolbars.
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Menu") {
                    CategoriesView()
                        .environment(productViewModel)
                        .environment(panelViewModel)
                }
                NavigationLink("Orders") {
                    OrdersView()
                        .environment(ordersViewModel)
                        .environment(panelViewModel)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Admin Panel")
            .alert(
                "Error",
                isPresented: Binding<Bool> (
                    get: { panelViewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented { panelViewModel.errorMessage = nil }
                    }
                )
            ) {
                Button(role: .close) {
                    panelViewModel.errorMessage = nil
                }
            } message: {
                Text(panelViewModel.errorMessage ?? "Error occurred!")
            }
        } content: {
            Text("Select an item")
        } detail: {
            Text("Details")
        }
        .toolbar {
            toolbar
        }
        .task {
            do {
                try await productViewModel.loadData()
                try await ordersViewModel.loadData()
            } catch let error as UserRepresentableError {
                panelViewModel.errorMessage = error.userMessage
            } catch is CancellationError {
                
            }
            catch {
                LoggerConfig.shared.logCore(level: .error, "Unknown error on loading data \(error.localizedDescription)")
                panelViewModel.errorMessage = "Unknown error. Please try again later."
            }
        }
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            if panelViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.5)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: panelViewModel.isLoading
                    )
            }
        }
    }
}

