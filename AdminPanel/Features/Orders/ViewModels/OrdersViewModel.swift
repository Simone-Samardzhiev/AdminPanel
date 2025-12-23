//
//  OrdersViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import os

/// View models responsible for loading orders and coordinating loading state with `PanelViewModel`
@Observable
@MainActor
final class OrdersViewModel {
    /// Service used to rest API operations.
    @ObservationIgnored private let orderService: OrderServiceProtocol
    
    /// Service used for WebSocket API operations.
    @ObservationIgnored private let orderWebSocketService: OrderWebSocketServiceProtocol
    
    /// Task listening for WebSocket events.
    @ObservationIgnored private var listenerTask: Task<Void, Never>?
    
    /// Credentials used to authenticate.
    @ObservationIgnored private  let credentials: Credentials
    
    /// QR code generator used to generate QR codes for sessions.
    @ObservationIgnored private let qrCodeGenerator: QRCodeGeneratorProtocol
    
    /// Array holding all order sessions.
    var orderSessions: [OrderSession]
    
    @ObservationIgnored private var mapOrderSessionIdToIndex: [UUID: Int]
    
    /// Array holding the ordered products
    var orderedProducts: [OrderedProduct]
    
    @ObservationIgnored private var mapOrderedProductIdToIndex: [UUID: Int]
    
    
    /// Default initializer.
    /// - Parameters:
    ///   - credentials: Credentials used to authenticate.
    ///   - orderService: The service used to make rest  API requests.
    ///   - orderWebSocketService: The service used to send messages over WebSocket.
    ///   - qrCodeGenerator: Generator for QR codes for sessions.
    init(
        credentials: Credentials,
        orderService: OrderServiceProtocol,
        orderWebSocketService: OrderWebSocketServiceProtocol,
        qrCodeGenerator: QRCodeGeneratorProtocol
    ) {
        self.credentials = credentials
        
        self.orderService = orderService
        self.orderWebSocketService = orderWebSocketService
        self.qrCodeGenerator = qrCodeGenerator
        
        self.orderSessions = []
        self.mapOrderSessionIdToIndex = [:]
        
        self.orderedProducts = []
        self.mapOrderedProductIdToIndex = [:]
    }
    
    /// Function that loads necessary data to display orders
    func loadData() async throws(HTTPError) {
        self.orderSessions = try await orderService.getOrderSessions(credentials: credentials)
        self.orderedProducts = try await orderService.getOrderedProducts(credentials: credentials)
        loadHelperData()
    }
    
    private func loadHelperData() {
        mapOrderSessionIdToIndex.reserveCapacity(orderSessions.count)
        for (index, session) in orderSessions.enumerated() {
            mapOrderSessionIdToIndex[session.id] = index
        }
        
        mapOrderedProductIdToIndex.reserveCapacity(orderedProducts.count)
        for (index, orderedProduct) in orderedProducts.enumerated() {
            mapOrderedProductIdToIndex[orderedProduct.id] = index
        }
    }
    
    /// Function that will generate a PDF file for a specific order session.
    /// - Parameters:
    ///   - orderSession: The order session for the PDF file.
    func generatePDF(orderSession: OrderSession) async throws(OrderSessionError) {
        let sessionIdString = orderSession.id.uuidString
        
        let sessionURL = APIClient.shared.restURL
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
            mapOrderSessionIdToIndex[session.id] = (orderSessions.count - 1)
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
            
            orderSessions.removeAll { $0.id == id }
            mapOrderSessionIdToIndex.removeValue(forKey: id)
        } catch {
            throw .network(error)
        }
        
    }
    
    /// Gets an order session id.
    /// - Parameter id: The id of the session.
    /// - Returns: The session with corresponding id.
    func getOrderSessionById(_ id: UUID) -> OrderSession? {
        guard let index = mapOrderSessionIdToIndex[id] else {
            return nil
        }
        
        return orderSessions[index]
    }
    
    /// Function that filters ordered products by status.
    /// - Parameter status: The status used for filtering.
    /// - Returns: The filtered ordered products.
    func orderedProductsByStatus(_ status: OrderedProduct.Status) -> [OrderedProduct] {
        return orderedProducts.filter { $0.status == status }
    }
    
    /// Start listening for WebSocket events.
    func startListening() {
        listenerTask?.cancel()
        
        listenerTask = Task {
            do {
                let stream = orderWebSocketService.connect(credentials)
                
                for try await event in stream {
                    await handleWebSocketEvent(event)
                }
            } catch {
                LoggerConfig.shared.logNetwork(level: .error, "Error receiving message from WebSocket \(error.localizedDescription)")
            }
        }
    }
    
    /// Function that handles WebSocket events and updates the view.
    /// - Parameter event: Event to be handled.
    private func handleWebSocketEvent(_ event: WebSocketEvent) async {
        switch event {
        case .order(let order):
            let orderedProduct = OrderedProduct(
                    id: order.id,
                    productId: order.productId,
                    status: order.status,
                    orderSessionId: order.sessionId
                )
        
            orderedProducts.append(orderedProduct)
            mapOrderedProductIdToIndex[orderedProduct.id] = orderedProducts.count - 1
        case .delete(let delete):
            guard let index = mapOrderedProductIdToIndex[delete.id] else {
                break
            }
            
            orderedProducts.remove(at: index)
            mapOrderedProductIdToIndex = Dictionary(
                uniqueKeysWithValues: orderedProducts
                    .enumerated()
                    .map({($0.element.id, $0.offset)})
            )
            
        case .updateOrderSession(let update):
            guard let index = mapOrderSessionIdToIndex[update.id] else {
                break
            }
            
            orderSessions[index].tableNumber = update.tableNumber
            orderSessions[index].status = update.status
        case .sessionPaid(let pay):
            guard let index = mapOrderSessionIdToIndex[pay.id] else {
                break
            }
            
            orderSessions[index].status = .paid
            
            orderedProducts.removeAll { $0.orderSessionId == pay.id }
            mapOrderedProductIdToIndex = Dictionary(
                uniqueKeysWithValues: orderedProducts
                    .enumerated()
                    .map({($0.element.id, $0.offset)})
            )
        }
    }
    
    /// Stops the task listening for WebSocket events.
    func stopListening() {
        listenerTask?.cancel()
    }
    
    /// Sends a WebSocket message for deleting an ordered product.
    /// - Parameter id: The id of the ordered product to be deleted.
    func deleteOrderedProduct(_ id: UUID) async {
        do {
            try await orderWebSocketService.send(.delete(.init(id: id)))
        } catch {
            LoggerConfig.shared.logNetwork(level: .error, "Error sending message with WebSocket \(error.localizedDescription)")
        }
    }
}
