//
//  AuthService.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 10.11.25.
//

import Foundation

/// Service responsible for authenticating users against the backend.
///
/// Conforming types perform network requests to validate credentials and return
/// a lightweight boolean indicating success.
protocol AuthenticationServiceProtocol {
    /// Attempts to authenticate with the provided credentials.
    /// - Parameters:
    ///   - username: The username to authenticate.
    ///   - password: The password to authenticate.
    /// - Returns: `true` when the server confirms the credentials, `false` for 401.
    /// - Throws: `HTTPError` when the request fails or an unexpected response is returned.
    func login(username: String, password: String) async throws(HTTPError) -> Bool
}

/// Default implementation of `AuthenticationServiceProtocol` backed by `URLSession`.
final class AuthenticationService {
    
}

/// URLSession-based implementation of the authentication API.
extension AuthenticationService: AuthenticationServiceProtocol {
    /// Performs a Basic-auth GET request to the `/admin/login` endpoint.
    ///
    /// Encodes the username and password into an `Authorization` header and interprets
    /// `200` as success, `401` as invalid credentials, and all other statuses as errors.
    func login(username: String, password: String) async throws(HTTPError) -> Bool {
        let credentials = "\(username):\(password)"
        let data = Data(credentials.utf8)
        let base64Credentials = data.base64EncodedString()
        
        let url = APIClient.shared.url
            .appending(path: "admin")
            .appending(path: "login")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        let response: URLResponse
        
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw HTTPError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return true
        case 401:
            return false
        default:
            throw HTTPError.invalidStatusCode(httpResponse.statusCode)
        }
    }

}
