//
//  Data+extensions.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import Foundation

extension Data {
    #if canImport(Cocoa)
    func download(filename: String) async {
        let (result, pannel) = await SavePanel.savePanel(filename: filename)
        guard result == .OK else {
            Logster.general.warning("could not save file; result='\(result.rawValue)'")
            return
        }

        guard let saveURL = await pannel.url else {
            Logster.general.warning("could not save file, because no url found for some reason.")
            return
        }

        do {
            try write(to: saveURL)
        } catch {
            Logster.general.error(label: "error while writing data to file", error: error)
            return
        }

        Logster.general.info("file saved")
    }
    #endif
}
