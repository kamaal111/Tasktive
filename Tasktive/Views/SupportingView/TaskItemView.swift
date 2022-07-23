//
//  TaskItemView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI

struct TaskItemView: View {
    let task: AppTask

    var body: some View {
        Text(task.title)
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(task: try! CoreTask.list(from: PersistenceController.preview.context).get().first!.asAppTask)
    }
}
