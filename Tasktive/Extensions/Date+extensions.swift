//
//  Date+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

import Foundation

extension Date {
    func incrementByDays(_ days: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = days

        guard let incrementedDate = Calendar.current.date(byAdding: dateComponent, to: self) else { return self }

        return incrementedDate
    }

    func incrementBySeconds(_ seconds: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.second = seconds

        guard let incrementedDate = Calendar.current.date(byAdding: dateComponent, to: self) else { return self }

        return incrementedDate
    }
}
