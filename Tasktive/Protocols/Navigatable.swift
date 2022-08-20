//
//  Navigatable.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import Foundation

protocol Navigatable {
    var pathKey: String { get }
    func shouldNavigate(pathItem: Dictionary<String, String>.Element) throws -> Bool
}
