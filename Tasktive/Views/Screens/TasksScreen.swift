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
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .navigationTitle(Text(SCREEN.title))
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
