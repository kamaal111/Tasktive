//
//  CoreDataViewerScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG
import SwiftUI
import SalmonUI
import ShrimpExtensions

struct CoreDataViewerScreen: View {
    @EnvironmentObject private var tasksViewModel: TasksViewModel

    @State private var selectedType = CoreTask.description()

    private let recordTypes: [String] = [
        CoreTask.description(),
    ]

    var body: some View {
        VStack {
            Picker(selection: $selectedType, label: Text.empty()) {
                ForEach(recordTypes, id: \.self) { recordType in
                    Text(recordType)
                        .tag(recordType)
                }
            }
            .labelsHidden()
            .frame(maxWidth: 200)
            .ktakeWidthEagerly(alignment: .trailing)
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 2) {
                    ForEach(headerTitles, id: \.self) { title in
                        gridItemView(text: title)
                            .background(Color.accentColor)
                    }
                    ForEach(databaseItems) { configuration in
                        ForEach(configuration.gridKeys(sortedWith: headerTitles)) { key in
                            gridItemView(text: configuration.values[key.keyValue]!)
                                .background(Color.secondary)
                        }
                    }
                }
            }
        }
        #if os(macOS)
        .padding(.vertical, .medium)
        .padding(.horizontal, .medium)
        .ktakeSizeEagerly(alignment: .topLeading)
        #endif
    }

    private var databaseItems: [GridItemConfiguration] {
        switch selectedType {
        case CoreTask.description():
            return tasksViewModel
                .allTasksSortedByCreationDate
                .filter { $0.source == .coreData }
                .map(\.gridConfiguration)
        default:
            return []
        }
    }

    private var headerTitles: [String] {
        databaseItems
            .first?
            .values
            .map(\.key)
            .sortedAlphabetically(andStartWith: "ID") ?? []
    }

    private var columns: [GridItem] {
        (0 ..< headerTitles.count)
            .map { _ in
                GridItem(.flexible())
            }
    }

    private func gridItemView(text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .padding(.horizontal, .extraSmall)
            .padding(.vertical, .extraSmall)
            .ktakeWidthEagerly(alignment: .leading)
    }
}

struct CoreDataViewerScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataViewerScreen()
            .environmentObject(TasksViewModel(preview: true))
    }
}
#endif
