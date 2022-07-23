//
//  TaskDetailsSheet.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI

struct TaskDetailsSheet: View {
    let task: AppTask?

    var body: some View {
        Text("Hello, World!")
    }
}

struct TaskDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsSheet(task: nil)
    }
}
