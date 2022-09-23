//
//  LogHolder.swift
//
//
//  Created by Kamaal M Farah on 20/09/2022.
//

import SwiftUI

/// Actor class that holds all the logs.
public actor LogHolder {
    private var items = Queue<HoldedLog>(max: 100)

    /// Computed array of logs.
    public var logs: [HoldedLog] {
        items.list
    }

    /// This method adds a log to the queue.
    /// - Parameter log: The log to add.
    public func addLog(_ log: HoldedLog) {
        items.enqueue(log)
    }

    /// Singleton of ``LogHolder`` to be used globally.
    public static let shared = LogHolder()
}

/// An representation of a log.
public struct HoldedLog: Hashable {
    /// The label of the log.
    public let label: String
    /// The type of the log as ``LogTypes``.
    public let type: LogTypes
    /// The message that was logged.
    public let message: String
    /// The time the log has been logged.
    public let timestamp: Date

    /// Memberwise initializer.
    /// - Parameters:
    ///   - label: The label of the log.
    ///   - type: The type of the log as ``LogTypes``.
    ///   - message: The message that was logged.
    ///   - timestamp: The time the log has been logged.
    public init(label: String, type: LogTypes, message: String, timestamp: Date) {
        self.label = label
        self.type = type
        self.message = message
        self.timestamp = timestamp
    }

    /// The different kind of logs.
    public enum LogTypes: String {
        case error
        case warning
        case info

        /// Representation color.
        public var color: Color {
            switch self {
            case .info:
                return .green
            case .warning:
                return .yellow
            case .error:
                return .red
            }
        }
    }
}

struct Queue<T> {
    private(set) var list: [T] = []
    let max: Int?

    init(max: Int? = nil) {
        self.max = max
    }

    var count: Int {
        list.count
    }

    mutating func enqueue(_ element: T) {
        if let max = max, count >= max {
            while count >= max {
                dequeue()
            }
        }

        list.append(element)
    }

    @discardableResult
    mutating func dequeue() -> T? {
        guard !list.isEmpty else { return nil }

        return list.removeFirst()
    }
}
