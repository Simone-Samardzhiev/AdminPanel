//
//  LoginViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import Foundation
import OSLog

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
    var isLoading: Bool
    
    /// The service used to perform authentication requests.
    @ObservationIgnored let authenticationService: AuthenticationServiceProtocol
    
    /// Creates a new view model with its dependencies.
    /// - Parameters:
    ///   - authenticationService: Service that performs the network login.
    init(_ authenticationService: AuthenticationServiceProtocol) {
        self.username = ""
        self.password = ""
        self.errorMessage = nil
        self.isLoading = false
        self.authenticationService = authenticationService
    }
    
    /// Attempts to sign in with the current `username` and `password`.
    /// - Throws: HTTPError if the service call fails.
    /// - Returns: Bool variable representing if the login was successful.
    func login() async throws(HTTPError)  -> Bool {
        isLoading = true
        defer {
            isLoading = false
        }
        
        return try await authenticationService.login(username: username, password: password)
    }
}
