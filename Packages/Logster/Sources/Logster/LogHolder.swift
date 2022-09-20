//
//  LogHolder.swift
//
//
//  Created by Kamaal M Farah on 20/09/2022.
//

import Foundation

/// Actor class that holds all the logs.
public actor LogHolder {
    private var items = Queue<HoldedLog>(max: 100)

    /// This method adds a log to the queue.
    /// - Parameter log: The log to add.
    public func addLog(_ log: HoldedLog) {
        items.enqueue(log)
    }

    /// Singleton of ``LogHolder`` to be used globally.
    public static let shared = LogHolder()
}

/// An representation of a log.
public struct HoldedLog {
    /// The label of the log.
    public let label: String
    /// The type of the log as ``LogTypes``.
    public let type: LogTypes
    /// The message that was logged.
    public let message: String

    /// Memberwise initializer.
    /// - Parameters:
    ///   - label: The label of the log.
    ///   - type: The type of the log as ``LogTypes``.
    ///   - message: The message that was logged.
    public init(label: String, type: LogTypes, message: String) {
        self.label = label
        self.type = type
        self.message = message
    }

    /// The different kind of logs.
    public enum LogTypes: String {
        case error
        case warning
        case info
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
