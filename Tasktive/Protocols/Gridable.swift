//
//  Gridable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 21/08/2022.
//

import Foundation

protocol Gridable {
    var dictionary: [String: String] { get }
    var idString: String { get }
}

extension Gridable {
    var gridConfiguration: GridItemConfiguration {
        GridItemConfiguration(id: idString, values: dictionary)
    }
}
