//
//  PanelViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 11.11.25.
//

import Foundation

/// An observable view model that tracks global UI state for the admin panel.
///
/// Currently only exposes a loading indicator flag used by multiple screens.
@Observable
@MainActor
final class PanelViewModel {
    /// Indicates whether a background operation is in progress.
    var isLoading: Bool
    
    /// Creates a new panel view model with `isLoading` defaulting to `false`.
    init() {
        self.isLoading = false
    }
}
