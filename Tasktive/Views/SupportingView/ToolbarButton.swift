//
//  ToolbarButton.swift
//  Tasktive
//
//  Created by Kamaal Farah on 24/07/2022.
//

import SwiftUI
import TasktiveLocale

struct ToolbarButton: View {
    let text: String
    let action: () -> Void

    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    init(localized: TasktiveLocale.Keys, action: @escaping () -> Void) {
        self.init(text: localized.localized, action: action)
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
}

struct ToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarButton(text: "Close", action: { })
            .previewLayout(.sizeThatFits)
    }
}
