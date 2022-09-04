//
//  EditMode.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 04/09/2022.
//

import SwiftUI

enum EditMode {
    case active
    case inactive

    var isEditing: Bool {
        self == .active
    }
}

struct EditModeKey: EnvironmentKey {
    static let defaultValue: EditMode = .inactive
}

extension EnvironmentValues {
    var editMode: EditMode {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
    }
}
