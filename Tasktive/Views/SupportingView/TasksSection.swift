//
//  TasksSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI

struct TasksSection: View {
    let tasks: [AppTask]

    var body: some View {
        // - TODO: LOCALIZE THIS
        Section(header: Text("Tasks")) {
            ForEach(tasks, id: \.self) { task in
                TaskItemView(task: task)
            }
        }
    }
}

struct TasksSection_Previews: PreviewProvider {
    static var previews: some View {
        TasksSection(tasks: [])
    }
}
