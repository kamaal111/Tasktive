//
//  QuickAddSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 20/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale

struct QuickAddSection: View {
    @Binding var title: String
    @Binding var currentSource: DataSource

    let disableSubmit: Bool
    let dataSources: [DataSource]
    let submit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .bold()
                .padding(.top, 12)
            KFloatingTextField(text: $title, title: TasktiveLocale.getText(.NEW_TASK_INPUT_TITLE))
                .onSubmit {
                    guard !disableSubmit else { return }
                    submit()
                }
            if dataSources.count > 1 {
                Picker(selection: $currentSource, label: Text.empty()) {
                    ForEach(dataSources, id: \.self) { source in
                        Image(systemName: source.persistanceMethodImageName)
                            .tag(source)
                            .ktakeWidthEagerly()
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 60)
            }
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
