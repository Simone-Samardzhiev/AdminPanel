//
//  OrdersViewModel.swift
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
final class OrdersViewModel {
    /// Service used to API operations.
    @ObservationIgnored let orderService: OrderServiceProtocol
    /// Credentials used to authenticate.
    @ObservationIgnored let credentials: Credentials
    
    /// QR code generator used to generate QR codes for sessions.
    @ObservationIgnored let qrCodeGenerator: QRCodeGeneratorProtocol
    
    /// Array holding all order sessions.
    var orderSessions: [OrderSession]
    
    /// Array holding the ordered products
    var orderedProducts: [OrderedProduct]
    
    /// Default initializer.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - orderService: The service used to make API requests.
    ///   - qrCodeGenerator: Generator for QR codes for sessions.
    init(credentials: Credentials, orderService: OrderServiceProtocol, qrCodeGenerator: QRCodeGeneratorProtocol) {
        self.credentials = credentials
        self.orderService = orderService
        self.qrCodeGenerator = qrCodeGenerator
        self.orderSessions = []
        self.orderedProducts = []
    }
    
    /// Function that loads necessary data to display orders
    func loadData() async throws(HTTPError) {
        self.orderSessions = try await orderService.getOrderSessions(credentials: credentials)
        self.orderedProducts = try await orderService.getOrderedProducts(credentials: credentials)
    }
    
    /// Function that will generate a PDF file for a specific order session.
    /// - Parameters:
    ///   - orderSession: The order session for the PDF file.
    func generatePDF(orderSession: OrderSession) async throws(OrderSessionError) {
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
            throw .errorCreatingPDFFile
        }
        
        let panel = NSSavePanel()
        panel.title = "Save QR Code"
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = sessionIdString
        panel.prompt = "Save"
        
        let result = await panel.begin()
          switch result {
          case .OK:
              guard let url = panel.url else {
                  throw .errorCreatingPDFFile
              }
              do {
                  try fileData.write(to: url)
              } catch {
                  throw .errorCreatingPDFFile
              }
          default:
              break
          }
    }
    
    /// Function to create a new order session
    /// - Parameter panelViewModel: ViewModel to report any errors.
    func createOrderSession() async throws(OrderSessionError) {
        do {
            let session = try await orderService.createSession(credentials: credentials)
            orderSessions.append(session)
        } catch {
            throw .network(error)
        }
    }
    
    /// Function to delete a session by id.
    /// - Parameters:
    ///   - id: The id of the session.
    func deleteOrderSession(id: UUID) async throws(CategoryError) {
        do {
            try await orderService.deleteSession(credentials: credentials, id: id)
        } catch {
            throw .network(error)
        }
        
        orderSessions.removeAll { $0.id == id }
    }
    
    /// Function that filters ordered products by status.
    /// - Parameter status: The status used for filtering.
    /// - Returns: The filtered ordered products.
    func orderedProductsByStatus(status: OrderedProduct.Status) -> [OrderedProduct] {
        return orderedProducts.filter { $0.status == status }
    }
}
