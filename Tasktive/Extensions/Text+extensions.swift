//
//  Text+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/07/2022.
//

import SwiftUI
import TasktiveLocale

extension Text {
    init(localized: TasktiveLocale.Keys) {
        self.init(localized.localized)
    }

    init(localized: TasktiveLocale.Keys, with variables: CVarArg...) {
        self.init(localized.localized(with: variables))
    }
}
