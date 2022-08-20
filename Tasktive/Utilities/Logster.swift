//
//  Logster.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 15/07/2022.
//

import OSLog
import Foundation

struct Logster {
    let logger: Logger

    init<T>(from type: T.Type) {
        self.init(label: String(describing: type))
    }

    init(label: String) {
        self.logger = .init(subsystem: Constants.bundleIdentifier, category: label)
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }

    func error(label: String, error: Error) {
        self.error([label, "description='\(error.localizedDescription)'", "error='\(error)'"].joined(separator: "; "))
    }

    func warning(_ message: String) {
        logger.warning("\(message)")
    }

    func info(_ message: String) {
        logger.info("\(message)")
    }

    static let general = Logster(label: "Tasktive")
}
