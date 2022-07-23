//
//  ProgressSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import ShrimpExtensions
import TasktiveLocale

struct ProgressSection: View {
    let currentDate: Date
    let progress: Double

    var body: some View {
        // - TODO: LOCALIZE THIS
        Section(header: Text("Progress")) {
            HStack {
                VStack(alignment: .leading) {
                    Text(formattedDate)
                    HStack {
                        ForEach(currentDate.datesOfWeek(weekOffset: 0), id: \.self) { date in
                            DayNumbersRowItem(date: date, activeDate: currentDate)
                        }
                    }
                }
                .ktakeSizeEagerly(alignment: .topLeading)
                .padding(.vertical, .small)
                .padding(.trailing, .small)
                Spacer()
                CircularProgressBar(
                    progress: progress,
                    lineWidth: 8
                )
                .frame(width: 80, height: 80)
                .padding(.vertical, .small)
                .foregroundColor(.accentColor)
            }
        }
    }

    var formattedDate: String {
        let now = Date()

        if currentDate.isYesterday {
            return TasktiveLocale.Keys.YESTERDAY.localized
        }
        if currentDate.isSameDay(as: now) {
            return TasktiveLocale.Keys.TODAY.localized
        }
        if currentDate.isTomorrow {
            return TasktiveLocale.Keys.TOMORROW.localized
        }
        return Self.taskDateFormatter.string(from: currentDate)
    }

    private static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct ProgressSection_Previews: PreviewProvider {
    static var previews: some View {
        ProgressSection(currentDate: Date(), progress: 0.2)
    }
}
