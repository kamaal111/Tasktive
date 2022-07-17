//
//  TasksScreen.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale
import ShrimpExtensions

private let SCREEN: NamiNavigator.Screens = .tasks

struct TasksScreen: View {
    @EnvironmentObject private var tasksViewModel: TasksViewModel

    var body: some View {
        VStack {
            List {
                ForEach(tasksViewModel.taskDates, id: \.self) { date in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(tasksViewModel.tasksForDate(date), id: \.self) { task in
                            Text(task.title)
                        }
                    }
                }
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

    func formattedDate(_ date: Date) -> String {
        let now = Date()

        #warning("not working for some reason")
        if date.isPreviousDay(of: now) {
            return TasktiveLocale.Keys.YESTERDAY.localized
        }
        if date.isSameDay(as: now) {
            return TasktiveLocale.Keys.TODAY.localized
        }
        if date.isNextDay(of: now) {
            return TasktiveLocale.Keys.TOMORROW.localized
        }
        return Self.taskDateFormatter.string(from: date)
    }

    static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct TasksScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TasksScreen()
        }
        .previewEnvironment()
    }
}
