//
//  DataClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 02/09/2022.
//

import Skypiea
import Foundation

struct DataClient {
    let tasks: TasksClient

    init(persistenceController: PersistenceController, skypiea: Skypiea) {
        self.tasks = .init(persistenceController: persistenceController, skypiea: skypiea)
    }
}
