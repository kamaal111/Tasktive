//
//  TasksStore.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 01/10/2022.
//

import Foundation
import SharedModels

actor TasksStore {
    private(set) var store: [Date: [AppTask]]

    init() {
        self.store = [:]
    }

    func get(_ date: Date) -> [AppTask]? {
        store[date]
    }

    func set(_ tasks: [AppTask], forDate date: Date) {
        store[date] = tasks
    }
}
