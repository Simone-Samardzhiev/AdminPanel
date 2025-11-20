//
//  Logger.swift
//  AdminPanel
//
//  Created by Simone Samardzhiev on 20.11.25.
//

import Foundation
import OSLog

/// Centralized logging configuration for the AdminPanel app.
///
/// Provides dedicated loggers for network-related operations and core logic.
/// Supports logging messages at different levels and marks logs as public.
struct LoggerConfig {
    /// Shared singleton instance.
    static let shared: Self = .init()
    
    /// Logger for network-related events (API calls, responses, failures).
    private let networkLogger: Logger
    
    /// Logger for core logic events (business rules, validation errors, state issues).
    private let coreLogger: Logger
    
    /// Initializes the logger configuration with predefined subsystems and categories.
    init() {
        self.networkLogger = .init(subsystem: "com.simone.AdminPanel", category: "Network")
        self.coreLogger = .init(subsystem: "com.simone.AdminPanel", category: "Core")
    }
    
    /// Logs a message related to network operations.
    ///
    /// - Parameters:
    ///   - level: The severity level of the log (default is `.default`).
    ///   - message: The message to log. Marked as `.public` so it is not redacted in system logs.
    func logNetwork(level: OSLogType = .default, _ message: String) {
        networkLogger.log(level: level, "\(message, privacy: .public)")
    }
    
    /// Logs a message related to core business logic.
    ///
    /// - Parameters:
    ///   - level: The severity level of the log (default is `.default`).
    ///   - message: The message to log. Marked as `.public` so it is not redacted in system logs.
    func logCore(level: OSLogType = .default, _ message: String) {
        coreLogger.log(level: level, "\(message, privacy: .public)")
    }
}
