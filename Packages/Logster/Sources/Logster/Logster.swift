//
//  Logster.swift
//
//
//  Created by Kamaal M Farah on 20/09/2022.
//

import OSLog
import Foundation

public struct Logster {
    private let logger: Logger

    public init<T>(from type: T.Type) {
        self.init(label: String(describing: type))
    }

    public init(label: String) {
        self.logger = .init(subsystem: "io.kamaal.Tasktive", category: label)
    }

    public func error(_ message: String) {
        logger.error("\(message)")
    }

    public func error(label: String, error: Error) {
        self.error([label, "description='\(error.localizedDescription)'", "error='\(error)'"].joined(separator: "; "))
    }

    public func warning(_ message: String) {
        logger.warning("\(message)")
    }

    public func warning(_ messages: String...) {
        warning(messages.joined(separator: "; "))
    }

    public func info(_ message: String) {
        logger.info("\(message)")
    }

    public static let general = Logster(label: "Tasktive")
}
