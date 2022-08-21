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

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 2) {
                ForEach(headerTitles, id: \.self) { title in
                    gridItemView(text: title)
                        .background(Color.accentColor)
                }
                ForEach(tasksAsDictionary) { configuration in
                    ForEach(configuration.gridKeys(sortedWith: headerTitles)) { key in
                        gridItemView(text: configuration.values[key.keyValue]!)
                            .background(Color.secondary)
                    }
                }
            }
            #if os(macOS)
            .padding(.vertical, .medium)
            .padding(.horizontal, .medium)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }
    }

    private var tasksAsDictionary: [GridItemConfiguration] {
        var tasks: [GridItemConfiguration] = []
        for task in tasksViewModel.allTasksSortedByCreationDate {
            let dictionary = [
                "ID": task.id.uuidString,
                "Title": task.title,
                "Ticked": task.ticked ? "Yes" : "No",
            ]
            tasks.append(GridItemConfiguration(id: task.id.uuidString, values: dictionary))
        }
        return tasks
    }

    private var headerTitles: [String] {
        tasksAsDictionary
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

struct GridItemConfiguration: Identifiable, Hashable {
    let id: String
    let values: [String: String]

    func gridKeys(sortedWith headers: [String]) -> [GridKey] {
        headers
            .map { title in
                GridKey(objectID: id, keyValue: title)
            }
    }

    struct GridKey: Identifiable, Hashable {
        let objectID: String
        let keyValue: String

        var id: String {
            "\(objectID)-\(keyValue)"
        }
    }
}

struct CoreDataViewerScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataViewerScreen()
            .environmentObject(TasksViewModel(preview: true))
    }
}
#endif
