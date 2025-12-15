//
//  OrdersView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 15.12.25.
//

import SwiftUI

/// View displaying order sessions and order products.
struct OrdersView: View {
    @State var orderViewModel: OrderViewModel
    
    @Environment(PanelViewModel.self) var panelViewModel

    /// Default initializer.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - orderService: Service used to make API requests.
    ///   - qrCodeGenerator: Generator used to create QR codes for order sessions.
    init(credentials: Credentials, orderService: OrderServiceProtocol, qrCodeGenerator: QRCodeGeneratorProtocol) {
        self.orderViewModel = .init(
            orderService: orderService,
            credentials: credentials,
            qrCodeGenerator: qrCodeGenerator
        )
    }
    
    
    var body: some View {
        List {
            Button("Add product", systemImage: "plus"){
                Task {
                    await orderViewModel.createOrderSession(panelViewModel: panelViewModel)
                }
            }
            
            Section {
                NavigationLink("Order sessions") {
                    OrderSessionsView()
                        .environment(panelViewModel)
                        .environment(orderViewModel)
                }
            }
        }
        .listStyle(.sidebar)
    }
}
