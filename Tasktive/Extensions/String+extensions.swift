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
