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

    func replaceStore(with newStore: [TasksFetchedContext]) {
        store = newStore
    }

    @discardableResult
    func pop() -> TasksFetchedContext? {
        store.popLast()
    }
}
