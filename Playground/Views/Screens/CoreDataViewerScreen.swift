//
//  CoreDataViewerScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

#if DEBUG
import SwiftUI

struct CoreDataViewerScreen: View {
    @EnvironmentObject private var tasksViewModel: TasksViewModel

    @State private var selectedType = "CoreTask"

    private let recordTypes: [String] = [
        "CoreTask",
    ]

    var body: some View {
        DataViewer(
            selectedType: $selectedType,
            recordTypes: recordTypes,
            databaseItems: databaseItems,
            fetchData: { Task { await fetchData() } }
        )
    }

    private var databaseItems: [GridItemConfiguration] {
        switch selectedType {
        case "CoreTask":
            return tasksViewModel
                .allTasksSortedByCreationDate
                .filter { $0.source == .coreData }
                .map(\.gridConfiguration)
        default:
            return []
        }
    }

    private func fetchData() async {
        switch selectedType {
        case "CoreTask":
            try? await tasksViewModel.getAllTasks(from: [.coreData]).get()
        default:
            break
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
