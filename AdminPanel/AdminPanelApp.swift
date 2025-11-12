//
//  AdminPanelApp.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import SwiftUI

/// The app's entry point. Sets up the environment and controls the initial UI
/// based on the user's authentication state.
///
/// - Important: The `AuthenticationState` is stored as a `@State` and injected
///   into the environment so child views can observe and mutate it.
@main
struct AdminPanelApp: App {
    /// Global authentication state, shared with the view hierarchy via `.environment(...)`.
    @State var authenticationState = AuthenticationState()
    
    /// Declares the app's scene graph. Shows either `LoginView` or `PanelView`
    /// with animated transitions depending on `authenticationState.state`.
    var body: some Scene {
        WindowGroup {
            Group {
                switch authenticationState.state {
                case .authenticated(_):
                    PanelView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .notAuthenticated:
                    LoginView(authenticationState)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.smooth(duration: 0.5), value: authenticationState.state)
            .environment(authenticationState)
        }
    }
}

