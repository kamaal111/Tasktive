//
//  NavigationPath+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 16/08/2022.
//

import SwiftUI

extension NavigationPath {
    var asDictionaryArray: [[String: String]]? {
        get throws {
            guard let codable = codable else { return nil }

            let data = try JSONEncoder().encode(codable)
            let path = try JSONDecoder().decode([String].self, from: data)

            var bufferScreen = ""
            var pathItems: [[String: String]] = []
            for (index, pathItem) in path.enumerated() {
                if (index % 2) == 0 {
                    bufferScreen = pathItem
                } else {
                    pathItems.append([bufferScreen: pathItem])
                }
            }

            return pathItems
                .reversed()
        }
    }
}
