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
    func isNextDay(of date: Date) -> Bool {
        let selfDate = self
        return selfDate.dayNumberOfWeek == (date.dayNumberOfWeek + 1)
            && selfDate.weekNumber == date.weekNumber
            && selfDate.yearNumber == date.yearNumber
    }

    func isPreviousDay(of date: Date) -> Bool {
        let selfDate = self
        return selfDate.dayNumberOfWeek == (date.dayNumberOfWeek - 1)
            && selfDate.weekNumber == date.weekNumber
            && selfDate.yearNumber == date.yearNumber
    }
}
