//
//  PanelView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import SwiftUI

/// The main container view for the admin panel UI.
///
/// Displays a split view with a navigation list on the leading side and content
////detail placeholders. Shows a loading indicator in the toolbar when `isLoading` is true.
struct PanelView: View {
    /// Backing view model that exposes shared UI-state like loading.
    @State var viewModel: PanelViewModel
    
    /// Creates the panel view with a fresh `PanelViewModel` instance.
    init() {
        self.viewModel = PanelViewModel()
    }
    
    
    /// Renders the split-view layout and toolbars.
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Menu") {
                    CategoriesView(viewModel)
                }
            }
            .navigationTitle("Admin Panel")

        } content: {
            Text("Select an item")
        } detail: {
            Text("Details")
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.5)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                }
            }
        }
    }
}
#Preview {
    PanelView()
}

