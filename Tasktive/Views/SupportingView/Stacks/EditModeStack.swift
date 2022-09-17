//
//  EditModeStack.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 04/09/2022.
//

import SwiftUI

struct EditModeStack<Content: View>: View {
    #if os(macOS)
    @State private var editMode: EditMode = .inactive
    #endif

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
        #if os(macOS)
        .environment(\.editMode, editMode)
        .onReceive(NotificationCenter.default.publisher(for: .changeEditMode)) { output in
            if let newEditMode = output.object as? EditMode, newEditMode != editMode {
                withAnimation {
                    editMode = newEditMode
                }
            }
        }
        #endif
    }
}

struct EditModeStack_Previews: PreviewProvider {
    static var previews: some View {
        EditModeStack {
            Text("Hallo")
        }
    }
}
