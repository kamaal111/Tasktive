//
//  EditButton.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 04/09/2022.
//

import SwiftUI

struct EditButton: View {
    @Environment(\.editMode) var editMode

    var body: some View {
        Button(action: {
            NotificationCenter.default.post(
                name: .changeEditMode,
                object: editMode.isEditing ? EditMode.inactive : EditMode.active,
                userInfo: nil
            )
        }) {
            Text(localized: editMode.isEditing ? .DONE : .EDIT)
                .foregroundColor(.accentColor)
                .bold()
        }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton()
    }
}
