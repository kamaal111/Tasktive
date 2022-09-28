//
//  TasksClient.swift
//  Backend
//
//  Created by Kamaal M Farah on 28/09/2022.
//

import Skypiea
import CDPersist
import Foundation
import SharedModels

class TasksClient {
    private let persistenceController: PersistenceController
    private let skypiea: Skypiea

    init(persistenceController: PersistenceController, skypiea: Skypiea) {
        self.persistenceController = persistenceController
        self.skypiea = skypiea
    }
}
