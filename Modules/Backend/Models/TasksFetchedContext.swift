//
//  TasksFetchedContext.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 01/10/2022.
//

import Foundation
import SharedModels

struct TasksFetchedContext: Hashable, Equatable {
    let date: Date
    let dataSources: [DataSource]
}
