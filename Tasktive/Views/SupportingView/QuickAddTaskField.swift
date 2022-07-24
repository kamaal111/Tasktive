//
//  QuickAddTaskField.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

struct QuickAddTaskField: View {
    @Binding var title: String
    let disableSubmit: Bool
    let submit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .bold()
                .padding(.top, 12)
            KFloatingTextField(
                text: $title,
                title: TasktiveLocale.getText(.NEW_TASK_INPUT_TITLE),
                onCommit: {
                    guard !disableSubmit else { return }
                    submit()
                }
            )
            Button(action: submit) {
                Text(localized: .SUBMIT)
                    .foregroundColor(.accentColor)
            }
            .disabled(disableSubmit)
            .padding(.top, 12)
            .buttonStyle(.plain)
        }
    }
}

struct QuickAddTaskField_Previews: PreviewProvider {
    static var previews: some View {
        QuickAddTaskField(title: .constant("New"), disableSubmit: false, submit: { })
    }
}
