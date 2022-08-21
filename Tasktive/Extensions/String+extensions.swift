//
//  String+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import Foundation

extension String {
    var shellEncodedURL: String {
        replacingOccurrences(of: " ", with: "\\ \\").replacingOccurrences(of: ")", with: "\\)")
    }
}

extension Array where Element == String {
    func sortedAlphabetically(andStartWith startingKey: String) -> [String] {
        guard contains(startingKey) else { return self }

        // TODO: THINK OF A MORE EFFICIENT WAY TO DO THIS
        return [startingKey] + filter { $0 != startingKey }
    }
}
