//
//  LoginViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import Foundation
import SwiftUI

/// An observable view model that coordinates the login flow.
///
/// `LoginViewModel` validates input, invokes the `AuthenticationService`, and
/// updates `AuthenticationState` upon success or sets an error message upon failure.
///
/// - Note: This type runs on the main actor because it is observed by SwiftUI views.
@Observable
@MainActor
final class LoginViewModel {
    /// The username typed by the user.
    var username: String
    
    /// The password typed by the user.
    var password: String
    
    /// A user-presentable error message when sign-in fails.
    var errorMessage: String?
    
    /// Indicates whether a sign-in request is in flight.
    var isLoading: Bool = false
    
    /// The service used to perform authentication requests.
    @ObservationIgnored let authenticationService: AuthenticationService
    
    /// The shared authentication container used to reflect login success.
    let authenticationState: AuthenticationState
    
    /// Creates a new view model with its dependencies.
    /// - Parameters:
    ///   - authenticationService: Service that performs the network login.
    ///   - authenticationState: Shared state updated when sign-in succeeds.
    init(authenticationService: AuthenticationService, authenticationState: AuthenticationState) {
        self.username = ""
        self.password = ""
        self.errorMessage = nil
        self.authenticationService = authenticationService
        self.authenticationState = authenticationState
    }
    
    /// Attempts to sign in with the current `username` and `password`.
    ///
    /// Updates `isLoading` while the request is active, sets `errorMessage` on failure,
    /// and updates `authenticationState` on success.
    func signIn() async {
        errorMessage = nil
        isLoading = true
        defer {
            isLoading = false
        }
        
        let success: Bool
        
        do {
            success = try await authenticationService.login(username: username, password: password)
        } catch {
            errorMessage = "An error occurred while signing in. Please try again later."
#if DEBUG
            print("Error: \(error)")
#endif
            return
        }
        
        if success {
            authenticationState.state = .authenticated(.init(username: username, password: password))
        } else {
            errorMessage = "Wrong credentials"
        }
    }
}
