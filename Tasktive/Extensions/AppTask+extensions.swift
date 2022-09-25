//
//  AppTask.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import CloudKit
import Foundation
import SharedModels

extension AppTask: Gridable {
    var dictionary: [String: String] {
        [
            "ID": idString,
            "Title": title,
            "Ticked": ticked ? "Yes" : "No",
            "Due date": Self.dateFormatter.string(from: dueDate),
        ]
    }

    var idString: String {
        id.uuidString
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
