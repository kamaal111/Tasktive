//
//  AcknowledgementsScreen.swift
//
//
//  Created by Kamaal M Farah on 03/10/2022.
//

import SwiftUI
import Logster
import SalmonUI
import TasktiveLocale

private let logger = Logster(from: SettingsUI.AcknowledgementsScreen.self)

extension SettingsUI {
    public struct AcknowledgementsScreen: View {
        @State private var acknowledgements: AcknowledgementsFileContent?

        public init() { }

        public var body: some View {
            KScrollableForm {
                KSection(header: TasktiveLocale.getText(.PACKAGES)) {
                    ForEach(acknowledgements?.packages ?? [], id: \.self) { package in
                        Text(package.name)
                    }
                }
            }
            .onAppear {
                guard acknowledgements == nil,
                      let url = Bundle.module.url(forResource: "Acknowledgements", withExtension: "json") else {
                    return
                }

                let data: Data
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    logger.error(label: "failed to load acknowledgements", error: error)
                    return
                }

                let object: AcknowledgementsFileContent
                do {
                    object = try JSONDecoder().decode(AcknowledgementsFileContent.self, from: data)
                } catch {
                    logger.error(label: "failed to load acknowledgements", error: error)
                    return
                }

                logger.info("acknowledgements file loaded")
                acknowledgements = object
            }
        }
    }
}

struct AcknowledgementsFileContent: Hashable, Codable {
    let packages: [AcknowledgementPackage]
}

struct AcknowledgementPackage: Hashable, Codable {
    let name: String
    let url: URL
    let author: String
    let license: String?
}
