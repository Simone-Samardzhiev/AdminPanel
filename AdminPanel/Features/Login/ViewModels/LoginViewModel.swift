//
//  LoginViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import Foundation

/// View model for login page.
@Observable
@MainActor
final class LoginViewModel {
    var username: String
    var password: String
    var errorMessage: String?
    var isLoading: Bool = false
    @ObservationIgnored let authenticationService: AuthenticationService
    let authenticationState: AuthenticationState
    
    init(authenticationService: AuthenticationService, authenticationState: AuthenticationState) {
        self.username = ""
        self.password = ""
        self.errorMessage = nil
        self.authenticationService = authenticationService
        self.authenticationState = authenticationState
    }
    
    func signIn() async {
        isLoading = true
        let success: Bool
        defer { isLoading = false }
        
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
            errorMessage = "Wrong credentials!"
        }
    }
}
