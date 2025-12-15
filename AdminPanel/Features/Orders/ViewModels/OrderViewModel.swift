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
    
    /// Function that will generate a PDF file for a specific order session.
    /// - Parameters:
    ///   - orderSession: The order session for the PDF file.
    ///   - panelViewModel: ViewModel to report any errors.
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
    
    /// Function to create a new order session
    /// - Parameter panelViewModel: ViewModel to report any errors.
    func createOrderSession(panelViewModel: PanelViewModel) async {
        do {
            let session = try await orderService.createSession(credentials: credentials)
            orderSessions.append(session)
        } catch {
            panelViewModel.errorMessage = error.userMessage
        }
    }
    
    /// Function to delete a session by id.
    /// - Parameters:
    ///   - id: The id of the session.
    ///   - panelViewModel: ViewModel to report any errors.
    func deleteOrderSession(id: UUID, panelViewModel: PanelViewModel) async {
        do {
            try await orderService.deleteSession(credentials: credentials, id: id)
        } catch {
            panelViewModel.errorMessage = error.userMessage
        }
        
        orderSessions.removeAll { $0.id == id }
    }
}
