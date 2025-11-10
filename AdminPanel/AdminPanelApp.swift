//
//  AdminPanelApp.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import SwiftUI

@main
struct AdminPanelApp: App {
    @State var authenticationState = AuthenticationState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authenticationState.state {
                case .authenticated(_):
                    PanelView()
                case .notAuthenticated:
                    LoginView(authenticationState)
                }
            }
            .environment(authenticationState)
        }
    }
}
