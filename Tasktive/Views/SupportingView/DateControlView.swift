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
            KTappableButton(action: goToPreviousDay) {
                Image(systemName: "arrow.left")
                    .bold()
                    .foregroundColor(.accentColor)
            }
            Spacer()
            KTappableButton(action: goToToday) {
                Text(localized: .TODAY)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }
            Spacer()
            KTappableButton(action: goToNextDay) {
                Image(systemName: "arrow.right")
                    .bold()
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct DateControlView_Previews: PreviewProvider {
    static var previews: some View {
        DateControlView(goToPreviousDay: { }, goToToday: { }, goToNextDay: { })
    }
}
