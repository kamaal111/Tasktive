//
//  FileManager+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import Foundation

extension FileManager {
    func findDirectoryOrFile(inDirectory directory: URL, searchPath: String) throws -> URL? {
        let content = try contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: []
        )
        return content.find(by: \.lastPathComponent, is: searchPath)
    }
}
