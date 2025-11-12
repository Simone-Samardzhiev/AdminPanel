//
//  AuthenticationState.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// A simple, observable container for the app's authentication status.
///
/// `AuthenticationState` is injected into the environment and used by the
/// app entry point to decide whether to show the login flow or the admin panel.
/// It holds lightweight, in-memory credentials for the current session only.
///
/// - Note: This type is annotated with `@MainActor` because the value is observed by UI.
@Observable
@MainActor
final class AuthenticationState {
    /// A lightweight value type that holds the user's credentials for the current session.
    ///
    /// - Important: These values are kept in memory only and are not persisted. Do not
    ///   store sensitive information beyond the needs of the active session.
    struct Credentials {
        /// The username provided by the user.
        let username: String
        /// The password provided by the user.
        let password: String
    }
    /// Represents the current authentication status of the application.
    enum State: Equatable {
        /// The user is authenticated with the provided `Credentials`.
        case authenticated(Credentials)
        /// The user is not authenticated and should be presented with the login UI.
        case notAuthenticated

        /// Convenience flag that returns `true` when the state is `.authenticated`, otherwise `false`.
        var isAuthenticated: Bool {
            switch self {
            case .authenticated: return true
            case .notAuthenticated: return false
            }
        }

        /// Two states are considered equal when their authentication status matches,
        /// regardless of the underlying credentials.
        static func ==(left: Self, right: Self) -> Bool {
            left.isAuthenticated == right.isAuthenticated
        }
    }
    
    /// The current authentication state for the running app.
    var state: State
    
    /// Creates a new instance defaulting to `.notAuthenticated`.
    init() {
        self.state = .notAuthenticated
    }
}

