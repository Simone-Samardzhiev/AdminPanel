//
//  LoginView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import SwiftUI


/// Login view used to display login screen.
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    init(_ authenticationState: AuthenticationState) {
        self.viewModel = LoginViewModel(
            authenticationService: AuthenticationService(),
            authenticationState: authenticationState
        )
    }

    var body: some View {
        VStack(spacing: 24) {
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
            
            VStack(spacing: 16) {
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $viewModel.password)
            }
            
            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign in")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.isLoading)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}
