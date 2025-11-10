//
//  LoginViewModel.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 9.11.25.
//

import Foundation

@Observable
final class LoginViewModel {
    var username: String
    var password: String
    
    init() {
        self.username = ""
        self.password = ""
    }
}
