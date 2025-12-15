//
//  OrderSessionsView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 13.12.25.
//

import SwiftUI

/// View displaying order sessions.
struct OrderSessionsView: View {
    @Environment( OrderViewModel.self) var orderViewModel
    @Environment(PanelViewModel.self) var panelViewModel
    
    /// Columns for the `LazyVGrid`
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 220), spacing: 16),
        GridItem(.flexible(minimum: 220), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(orderViewModel.orderSessions) { session in
                    OrderSessionCard(session)
                        .environment(orderViewModel)
                }
            }
            .padding()
        }
        .task {
            await orderViewModel.loadData(panelViewModel: panelViewModel)
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
        @Environment(OrderViewModel.self) var orderViewModel
        
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
            .contextMenu {
                Button("Generate QR code", systemImage: "qrcode") {
                    orderViewModel.generatePDF(orderSession: session, panelViewModel: panelViewModel)
                }
                Button("Delete", systemImage: "trash") {
                    Task {
                        await orderViewModel.deleteOrderSession(id: session.id, panelViewModel: panelViewModel)
                    }
                }
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
}
