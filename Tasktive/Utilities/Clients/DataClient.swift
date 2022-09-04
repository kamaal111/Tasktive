//
//  DataClient.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 02/09/2022.
//

import Skypiea
import Foundation

class DataClient {
    let tasks: TasksClient

    init() {
        #if !DEBUG
        self.tasks = .init(persistenceController: .shared, skypiea: .shared)
        #else
        if CommandLineArguments.previewCoredata.enabled {
            self.tasks = .init(persistenceController: .preview, skypiea: .preview)
        } else {
            self.tasks = .init(persistenceController: .shared, skypiea: .shared)
        }
        #endif
    }

    #if DEBUG
    init(preview: Bool) {
        if preview || CommandLineArguments.previewCoredata.enabled {
            self.tasks = .init(persistenceController: .preview, skypiea: .preview)
        } else {
            self.tasks = .init(persistenceController: .shared, skypiea: .shared)
        }
    }
    #endif
}
