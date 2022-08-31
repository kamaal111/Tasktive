//
//  CoreTask+Taskable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation

extension CoreTask: Taskable {
    var source: DataSource {
        .coreData
    }
}
