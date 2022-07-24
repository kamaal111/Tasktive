//
//  ProgressSection.swift
//  Tasktive
//
//  Created by Kamaal Farah on 23/07/2022.
//

import SwiftUI
import SalmonUI
import TasktiveLocale
import ShrimpExtensions

struct ProgressSection: View {
    @Binding var currentDate: Date

    let progress: Double

    private static let circleSize: CGSize = .squared(80)

    var body: some View {
        Section(header: Text(localized: .PROGRESS)) {
            HStack {
                VStack(alignment: .leading) {
                    DatePicker("", selection: $currentDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .id(currentDate)
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
                .frame(width: Self.circleSize.width, height: Self.circleSize.height)
                .padding(.vertical, .small)
                .foregroundColor(.accentColor)
            }
        }
    }
}

struct ProgressSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ProgressSection(currentDate: .constant(Date()), progress: 0.2)
        }
    }
}
