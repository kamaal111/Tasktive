//
//  Array+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/07/2022.
//

import Foundation

// - TODO: MOVE TO SHRIMP EXTENSIONS
extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparison: ComparisonResult) -> [Element] {
        sorted(by: {
            switch comparison {
            case .orderedAscending:
                return $0[keyPath: keyPath] < $1[keyPath: keyPath]
            case .orderedDescending:
                return $0[keyPath: keyPath] > $1[keyPath: keyPath]
            case .orderedSame:
                return $0[keyPath: keyPath] == $1[keyPath: keyPath]
            }
        })
    }
}
