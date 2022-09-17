//
//  DispatchQueue+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 13/09/2022.
//

import Foundation

extension DispatchQueue {
    static let monitor = DispatchQueue(label: constructIdentifier(name: "Monitor"))

    private static func constructIdentifier(name: String) -> String {
        "DispatchQueue.\(Constants.bundleIdentifier).\(name)"
    }
}
