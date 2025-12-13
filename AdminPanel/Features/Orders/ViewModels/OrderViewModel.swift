//
//  OrderViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import Foundation

/// View models responsible for loading orders and coordinating loading state with `PanelViewModel`
@Observable
@MainActor
class OrderViewModel {
    /// Service used to API operations.
    @ObservationIgnored let orderService: OrderServiceProtocol
    /// Credentials used to authenticate.
    @ObservationIgnored let credentials: Credentials
    /// Array holding all order sessions.
    var orderSessions: [OrderSession]
    
    /// Default initializer.
    /// - Parameters:
    ///   - orderService: The service used to make API requests.
    ///   - credentials: Credentials used to authenticate.
    init(orderService: OrderServiceProtocol, credentials: Credentials) {
        self.orderService = orderService
        self.credentials = credentials
        self.orderSessions = []
    }
    
    /// Function that loads necessary data to display orders
    /// - Parameter panelViewModel: Panel view models used to update the state of the panel.
    func loadData(panelViewModel: PanelViewModel) async {
        panelViewModel.isLoading = true
        defer { panelViewModel.isLoading = false }
        
        do {
            self.orderSessions = try await orderService.getOrderSessions(credentials: credentials)
        } catch {
            panelViewModel.errorMessage = error.userMessage
        }
    }
}
