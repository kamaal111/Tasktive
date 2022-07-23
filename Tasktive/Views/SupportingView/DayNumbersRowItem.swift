//
//  DayNumbersRowItem.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI

struct DayNumbersRowItem: View {
    @Environment(\.colorScheme) var colorScheme

    let date: Date
    let activeDate: Date

    init(date: Date, activeDate: Date) {
        self.date = date
        self.activeDate = activeDate
    }

    var body: some View {
        Text("\(date.dayNumberOfWeek)")
            .font(.callout)
            .foregroundColor(numberColor)
            .background(backgroundView)
    }

    private var backgroundView: some View {
        let circleSize: CGSize = .squared(26)

        return KJustStack {
            if date.isSameDay(as: activeDate) {
                Circle()
                    .frame(width: circleSize.width, height: circleSize.height)
                    .foregroundColor(Color.accentColor)
                    .padding(.all, .extraSmall)
            }
        }
    }

    private var numberColor: Color {
        if date.isSameDay(as: activeDate) {
            return colorScheme == .dark ? .black : .white
        }

        if date.isSameDay(as: Date()) {
            return .accentColor
        }

        return .primary
    }
}

struct DayNumbersRowItem_Previews: PreviewProvider {
    static var previews: some View {
        DayNumbersRowItem(date: Date(), activeDate: Date())
    }
}
