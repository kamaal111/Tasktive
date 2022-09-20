//
//  Logster.swift
//
//
//  Created by Kamaal M Farah on 20/09/2022.
//

import OSLog
import Foundation

/// Main utility struct to handle logging.
public struct Logster {
    private let logger: Logger
    let label: String

    /// Initialize with type as label.
    /// - Parameter type: The type to name the label when logging.
    public init<T>(from type: T.Type) {
        self.init(label: String(describing: type))
    }

    /// Initialize with custom label.
    /// - Parameter label: The label to display when logging.
    public init(label: String) {
        self.label = label
        self.logger = .init(subsystem: "io.kamaal.Tasktive", category: label)
    }

    /// To log errors
    /// - Parameter message: The message to log.
    public func error(_ message: String) {
        logger.error("\(message)")
        addLogToQueue(type: .error, message: message)
    }

    /// To log errors formatted with an extra label.
    /// - Parameters:
    ///   - label: The label to show before the error.
    ///   - error: The error to log.
    public func error(label: String, error: Error) {
        let message = [label, "description='\(error.localizedDescription)'", "error='\(error)'"].joined(separator: "; ")
        self.error(message)
    }

    /// To log warnings.
    /// - Parameter message: The message to log.
    public func warning(_ message: String) {
        logger.warning("\(message)")
        addLogToQueue(type: .warning, message: message)
    }

    /// To log warnings.
    /// - Parameter messages: The messages to log separated by a `; `.
    public func warning(_ messages: String...) {
        warning(messages.joined(separator: "; "))
    }

    /// To log information.
    /// - Parameter message: The message to log.
    public func info(_ message: String) {
        logger.info("\(message)")
        addLogToQueue(type: .info, message: message)
    }

    private func addLogToQueue(type: HoldedLog.LogTypes, message: String) {
        Task { await LogHolder.shared.addLog(.init(label: label, type: type, message: message)) }
    }

    /// General logger labeled with `Tasktive`.
    public static let general = Logster(label: "Tasktive")
}
