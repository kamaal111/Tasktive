//
//  Shell.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

#if os(macOS)
import Foundation

struct Shell {
    private init() { }

    static func zsh(_ command: String) -> String {
        shell("/bin/zsh", command)
    }

    private static func shell(_ launchPath: String, _ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = launchPath
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}
#endif
