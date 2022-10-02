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

    func moveToEnd(_ source: Int) {
        append(remove(at: source))
    }

    @discardableResult
    func pop() -> TasksFetchedContext? {
        store.popLast()
    }

    @discardableResult
    func remove(at index: Int) -> TasksFetchedContext {
        store.remove(at: index)
    }

    func contains(_ context: TasksFetchedContext) -> Bool {
        store.contains(context)
    }
}
