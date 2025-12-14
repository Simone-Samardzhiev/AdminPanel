//
//  OrderViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

/// View models responsible for loading orders and coordinating loading state with `PanelViewModel`
@Observable
@MainActor
final class OrderViewModel {
    /// Service used to API operations.
    @ObservationIgnored let orderService: OrderServiceProtocol
    /// Credentials used to authenticate.
    @ObservationIgnored let credentials: Credentials
    
    /// QR code generator used to generate QR codes for sessions.
    @ObservationIgnored let qrCodeGenerator: QRCodeGeneratorProtocol
    
    /// Array holding all order sessions.
    var orderSessions: [OrderSession]
    
    /// Default initializer.
    /// - Parameters:
    ///   - orderService: The service used to make API requests.
    ///   - credentials: Credentials used to authenticate.
    init(orderService: OrderServiceProtocol, credentials: Credentials, qrCodeGenerator: QRCodeGeneratorProtocol) {
        self.orderService = orderService
        self.credentials = credentials
        self.qrCodeGenerator = qrCodeGenerator
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
    
    func generatePDF(orderSession: OrderSession, panelViewModel: PanelViewModel) {
        let sessionIdString = orderSession.id.uuidString
        
        let sessionURL = APIClient.shared.url
            .appending(path: "public")
            .appending(queryItems: [
                URLQueryItem(name: "session_id", value: sessionIdString)
            ])
            .absoluteString
        
        guard let fileData = qrCodeGenerator.generatePDF(
            text: sessionURL,
            title: sessionIdString,
            pageSize: CGSize(width: 595, height: 842),
            qrSize: 512
        ) else {
            panelViewModel.errorMessage = "Error creating PDF file"
            return
        }
        
        let panel = NSSavePanel()
        panel.title = "Save QR Code"
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = sessionIdString
        panel.prompt = "Save"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try fileData.write(to: url)
                } catch {
                    panelViewModel.errorMessage = "Error writing PDF file"
                }
            }
        }
    }
}
