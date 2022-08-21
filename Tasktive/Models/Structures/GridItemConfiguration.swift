//
//  GridItemConfiguration.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

import Foundation

struct GridItemConfiguration: Identifiable, Hashable {
    let id: String
    let values: [String: String]

    func gridKeys(sortedWith headers: [String]) -> [GridKey] {
        headers
            .map { title in
                GridKey(objectID: id, keyValue: title)
            }
    }

    struct GridKey: Identifiable, Hashable {
        let objectID: String
        let keyValue: String

        var id: String {
            "\(objectID)-\(keyValue)"
        }
    }
}
