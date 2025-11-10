//
//  AuthService.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Service responsible for handling user authentication.
protocol AuthenticationServiceProtocol {
    /// Attempts to log in user with the given credentials.
    /// - Parameters:
    ///   - username: The username of the user trying to log in.
    ///   - password: The password of the user trying to log in.
    /// - Returns: True if the credential are correct and false if not.
    func login(username: String, password: String) async throws(HTTPError) -> Bool
}

final class AuthenticationService {
    
}

extension AuthenticationService: AuthenticationServiceProtocol {
    func login(username: String, password: String) async throws(HTTPError) -> Bool {
        let credentials = "\(username):\(password)"
        let data = Data(credentials.utf8)
        let base64Credentials = data.base64EncodedString()
        
        let url = APIClient.shared.url.appending(path: "/admin/login")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        let response: URLResponse
        
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw HTTPError.requestFailed
        }
        
        guard let urlResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        
        switch urlResponse.statusCode {
        case 200:
            return true
        case 401:
            return false
        default:
            throw HTTPError.invalidResponse
        }
    }

}
