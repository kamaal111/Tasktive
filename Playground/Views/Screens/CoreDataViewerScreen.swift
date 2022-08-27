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

    @State private var selectedType = CoreTask.description()

    private let recordTypes: [String] = [
        CoreTask.description(),
    ]

    var body: some View {
        DataViewer(selectedType: $selectedType, recordTypes: recordTypes, databaseItems: databaseItems)
            .onAppear {
                Task { try? await tasksViewModel.getTodaysTasks().get() }
            }
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
}

struct CoreDataViewerScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataViewerScreen()
            .environmentObject(TasksViewModel(preview: true))
    }
}
#endif
