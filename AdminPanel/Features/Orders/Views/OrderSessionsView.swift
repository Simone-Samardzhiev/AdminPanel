//
//  OrderSessionsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import SwiftUI

/// View displaying order sessions.
struct OrderSessionsView: View {
    @Environment(OrdersViewModel.self) var ordersViewModel
    @Environment(PanelViewModel.self) var panelViewModel
    @State var editSession: OrderSession? = nil
    
    /// Columns for the `LazyVGrid`
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 220), spacing: 16),
        GridItem(.flexible(minimum: 220), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ordersViewModel.orderSessions) { session in
                    OrderSessionCard(session)
                        .environment(ordersViewModel)
                        .contextMenu {
                            Button("Generate QR code", systemImage: "qrcode") {
                                Task {
                                    do {
                                        panelViewModel.isLoading = true
                                        defer { panelViewModel.isLoading = false}
                                        
                                       try await ordersViewModel.generatePDF(orderSession: session)
                                    } catch let error as UserRepresentableError {
                                        panelViewModel.errorMessage = error.userMessage
                                    }
                                }
                            }
                            
                            Button("Delete", systemImage: "trash") {
                                Task {
                                    do {
                                        panelViewModel.isLoading = true
                                        defer { panelViewModel.isLoading = false}
                                        
                                        try await ordersViewModel.deleteOrderSession(id: session.id)
                                    } catch let error as UserRepresentableError {
                                        panelViewModel.errorMessage = error.userMessage
                                    }
                                }
                            }
                            
                            Button("Edit", systemImage: "pencil") {
                                editSession = session
                            }
                        }
                }
            }
            .padding()
        }
        .sheet(item: $editSession) { session in
            EditSessionSheet(session)
        }
    }
}

extension OrderSessionsView {
    /// StatusBadge displays status of the order.
    private struct StatusBadge: View {
        let status: OrderSession.Status
        
        var body: some View {
            Text(status.rawValue.uppercased())
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .foregroundStyle(statusColor)
                .clipShape(Capsule())
        }
        
        private var statusColor: Color {
            switch status {
            case .open: .green
            case .closed: .gray
            case .paid: .blue
            }
        }
    }
    
    /// Card displaying the order session.
    private struct OrderSessionCard: View {
        @Environment(OrdersViewModel.self) var orderViewModel
        
        @Environment(PanelViewModel.self) var panelViewModel
        
        let session: OrderSession
        
        @State private var isHovered: Bool
        
        init(_ session: OrderSession) {
            self.session = session
            self.isHovered = false
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                header
                Divider()
                details
            }
            .padding()
            .background(background)
            .glassEffect(in: .rect(cornerRadius: 10))
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }
        
        private var header: some View {
            HStack {
                Text("Session")
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: session.status)
            }
        }
        
        private var details: some View {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    "Table \(session.tableNumber)",
                    systemImage: "table.furniture"
                )
                .font(.subheadline)
                
                Text(session.id.uuidString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        
        private var background: some View {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.windowBackgroundColor))
        }
    }
    
    /// Sheet used to edit order session.
    private struct EditSessionSheet: View {
        @Environment(OrdersViewModel.self) var ordersViewModel
        @Environment(\.dismiss) var dismiss
        
        @State private var session: OrderSession
        
        init(_ session: OrderSession) {
            self.session = session
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit Session")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                statusPicker
                tableEdit
                
            }
            .padding(.all, 32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await ordersViewModel.updateOrderSession(session)
                            dismiss()
                        }
                    }
                }
            }
        }
        
        /// Picker for new session status.
        private var statusPicker: some View {
            Picker("Status", selection: $session.status) {
                ForEach(OrderSession.Status.allCases, id: \.self) { status in
                    Text(status.rawValue.capitalized)
                        .tag(status)
                }
            }
        }
        
        /// Text field for editing the table number.
        private var tableEdit: some View {
            LabeledContent("Table number") {
                TextField("Number", value: $session.tableNumber, formatter: Self.integerFormatter)
            }
        }
        
        /// Formatter for the `tableEdit`
        private static var integerFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.allowsFloats = false
            formatter.minimum = 1
            formatter.maximum = 1000
            formatter.generatesDecimalNumbers = false
            formatter.usesGroupingSeparator = false
            return formatter
        }
    }
}
