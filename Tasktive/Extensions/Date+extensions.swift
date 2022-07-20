//
//  Date+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation
import ShrimpExtensions

// - TODO: MOVE TO SHRIMP EXTENSIONS
extension Date {
    func isNextDay(of _: Date) -> Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    func isPreviousDay(of _: Date) -> Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isBeforeToday: Bool {
        let selfDate = self
        let today = Date()
        return (selfDate.dayNumberOfWeek < (today.dayNumberOfWeek) || selfDate.weekNumber < today.weekNumber) &&
            selfDate.yearNumber == today.yearNumber
    }
}
