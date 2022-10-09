//
//  QuickAddSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI
import SalmonUI
import SharedModels
import TasktiveLocale

struct QuickAddSection: View {
    @Binding var title: String
    @Binding var currentSource: DataSource

    let disableSubmit: Bool
    let dataSources: [DataSource]
    let submit: () -> Void

    private let topPaddingCorrection: CGFloat = 12

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .bold()
                .padding(.top, topPaddingCorrection)
            KFloatingTextField(text: $title, title: TasktiveLocale.getText(.NEW_TASK_INPUT_TITLE))
                .onSubmit {
                    guard !disableSubmit else { return }
                    submit()
                }
            if dataSources.count > 1 {
                DataSourcePicker(source: $currentSource, sources: dataSources, withLabel: false)
                    .padding(.top, topPaddingCorrection)
            }
            Button(action: submit) {
                Text(localized: .SUBMIT)
                    .foregroundColor(.accentColor)
            }
            .disabled(disableSubmit)
            .padding(.top, topPaddingCorrection)
            .buttonStyle(.plain)
        }
    }
}

struct QuickAddSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickAddSection(
            title: .constant("New"),
            currentSource: .constant(.coreData),
            disableSubmit: false,
            dataSources: DataSource.allCases,
            submit: { }
        )
    }
}
