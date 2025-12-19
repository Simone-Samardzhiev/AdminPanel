//
//  LoginView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import SwiftUI


/// A SwiftUI view that presents the sign-in form.
///
/// `LoginView` wires the UI to `LoginViewModel`, handles simple loading
/// states and error presentation, and triggers the sign-in task.
///
/// - Note: The view model is initialized with an `AuthenticationService` and
///   a shared `AuthenticationState` so that successful sign-in can update the
///   global app state.
/// Login view used to display login screen.
struct LoginView: View {
    @Environment(AuthenticationState.self) private var authenticationState
    @State private var loginViewModel: LoginViewModel
    
    /// Creates the login view and injects dependencies into its view model.
    init(_ service: AuthenticationServiceProtocol) {
        self.loginViewModel = LoginViewModel(service)
    }
    
    /// Renders the sign-in UI with fields for username and password, a sign-in button,
    /// and transient error messaging.
    var body: some View {
        VStack(spacing: 24) {
            title
            
            VStack(spacing: 16) {
                usernameField
                passwordField
            }
            
            loginButton
            
            // Error message with proper transition
            if let errorMessage = loginViewModel.errorMessage {
                Text(errorMessage)
                    .font(.headline.bold())
                    .foregroundStyle(.red.opacity(0.8))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .frame(maxWidth: 400)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: loginViewModel.errorMessage)
    }
    
    /// Header section containing icon and descriptive text.
    private var title: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            
            Text("Restaurant admin")
                .font(.title.bold())
                .foregroundStyle(Color.primary)
            
            Text("Sign in to manage your restaurant")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(.bottom, 40)
    }
    
    /// Text field bound to the user's username.
    private var usernameField: some View {
        TextField("Username", text: $loginViewModel.username)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textContentType(.username)
            .disabled(loginViewModel.isLoading)
            .opacity(loginViewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: loginViewModel.isLoading)
    }
    
    /// Secure field bound to the user's password.
    private var passwordField: some View {
        SecureField("Password", text: $loginViewModel.password)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .textContentType(.password)
            .disabled(loginViewModel.isLoading)
            .opacity(loginViewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: loginViewModel.isLoading)
    }
    
    /// Button that triggers the asynchronous sign-in process.
    private var loginButton: some View {
        Button {
            Task {
                do {
                    let success = try await loginViewModel.login()
                    if success {
                        authenticationState.state = .authenticated(
                            .init(
                                username: loginViewModel.username,
                                password: loginViewModel.password)
                        )
                    } else {
                        loginViewModel.errorMessage = "Wrong credentials!"
                        authenticationState.state = .notAuthenticated
                    }
                } catch let error as UserRepresentableError {
                    loginViewModel.errorMessage = error.userMessage
                }
            }
        } label: {
            if loginViewModel.isLoading {
                ProgressView()
                    .controlSize(.regular)
            } else {
                Text("Sign in")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: loginViewModel.isLoading)
        .buttonStyle(.glassProminent)
        .disabled(loginViewModel.isLoading)
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
    }
}

