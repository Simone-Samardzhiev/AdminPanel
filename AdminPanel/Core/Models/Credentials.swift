//
//  Credentials.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 14.11.25.
//

import Foundation


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
