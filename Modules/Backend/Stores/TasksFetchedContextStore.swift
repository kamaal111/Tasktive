//
//  TasksFetchedContextStore.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 01/10/2022.
//

import Foundation
import ShrimpExtensions

actor TasksFetchedContextStore {
    private(set) var store: [TasksFetchedContext]

    init() {
        self.store = []
    }

    func append(_ context: TasksFetchedContext) {
        store = store.appended(context)
    }

    @discardableResult
    func pop() -> TasksFetchedContext? {
        store.popLast()
    }

    @discardableResult
    func findAndRemoveIfTrue<T: Equatable>(
        by keyPath: KeyPath<TasksFetchedContext, T>,
        is comparisonValue: T,
        condition: (TasksFetchedContext) throws -> Bool
    ) rethrows -> Bool {
        try findAndRemoveIfTrue(where: { $0[keyPath: keyPath] == comparisonValue }, condition: condition)
    }

    @discardableResult
    func findAndRemoveIfTrue(
        where predicate: (TasksFetchedContext) throws -> Bool,
        condition: (TasksFetchedContext) throws -> Bool
    ) rethrows -> Bool {
        guard let itemIndex = try store.findIndex(where: predicate) else { return false }

        let item = store[itemIndex]
        guard try condition(item) else { return false }

        store.remove(at: itemIndex)
        return true
    }

    @discardableResult
    func findAndRemoveIfTrue(where predicate: (TasksFetchedContext) throws -> Bool) rethrows -> Bool {
        guard let itemIndex = try store.findIndex(where: predicate) else { return false }

        let item = store[itemIndex]

        store.remove(at: itemIndex)
        return true
    }
}
