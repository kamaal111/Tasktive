//
//  DateControlView.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

struct DateControlView: View {
    let goToPreviousDay: () -> Void
    let goToToday: () -> Void
    let goToNextDay: () -> Void

    var body: some View {
        HStack {
            button(
                action: goToPreviousDay,
                content: Image(systemName: "arrow.left").bold()
            )
            #if os(iOS)
            Spacer()
            #endif
            button(
                action: goToToday,
                content: Text(localized: .TODAY).fontWeight(.semibold)
            )
            #if os(iOS)
            Spacer()
            #endif
            button(
                action: goToNextDay,
                content: Image(systemName: "arrow.right").bold()
            )
        }
        #if os(macOS)
        .ktakeWidthEagerly(alignment: .trailing)
        #endif
    }

    private func button(action: @escaping () -> Void, content: some View) -> some View {
        let modifiedContent = content
            .foregroundColor(.accentColor)

        #if os(macOS)
        return Button(action: action) {
            modifiedContent
        }
        #else
        return KTappableButton(action: action) {
            modifiedContent
        }
        #endif
    }
}

struct DateControlView_Previews: PreviewProvider {
    static var previews: some View {
        DateControlView(goToPreviousDay: { }, goToToday: { }, goToNextDay: { })
    }
}
