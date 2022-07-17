//
//  TasksScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI

private let SCREEN: NamiNavigator.Screens = .tasks

struct TasksScreen: View {
    @EnvironmentObject private var tasksViewModel: TasksViewModel

    var body: some View {
        VStack {
            ForEach(tasksViewModel.tasks) { task in
                Text(task.title)
            }
        }
        .navigationTitle(Text(SCREEN.title))
        .onAppear(perform: {
            Task { await tasksViewModel.getAllTasks() }
        })
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct TasksScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TasksScreen()
        }
        .previewEnvironment()
    }
}
