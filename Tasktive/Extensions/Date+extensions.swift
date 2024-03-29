//
//  Date+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

import Logster
import Foundation

extension Date {
    var hashed: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: self)
        guard let hashedDate = Calendar.current.date(from: dateComponents) else {
            #if DEBUG
            fatalError("failed to hash date")
            #else
            Logster.general.warning("failed to hash date")
            return Date()
            #endif
        }

        return hashedDate
    }

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
