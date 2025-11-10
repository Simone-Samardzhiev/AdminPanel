//
//  LoginView.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import SwiftUI


struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var isLoading = false

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
                
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: 400)
        
    }
}


#Preview {
    LoginView()
}
