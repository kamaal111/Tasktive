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
        self.logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: type))
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }

    func warning(_ message: String) {
        logger.warning("\(message)")
    }

    func info(_ message: String) {
        logger.info("\(message)")
    }
}
