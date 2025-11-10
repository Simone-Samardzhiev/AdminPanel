//
//  AuthenticationState.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// AuthenticationState holds state whether user is authenticated or not authenticated.
@Observable
@MainActor
final class AuthenticationState {
    /// User's credentials
    struct Credentials {
        let username: String
        let password: String
    }
    /// Authentication state
    enum State {
        case authenticated(Credentials)
        case notAuthenticated
    }
    
    var state: State
    
    init() {
        self.state = .notAuthenticated
    }
}
