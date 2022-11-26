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
import InAppBrowserSUI

private let logger = Logster(from: SettingsUI.AcknowledgementsScreen.self)

extension SettingsUI {
    public struct AcknowledgementsScreen: View {
        @State private var acknowledgements: AcknowledgementsFileContent?
        @State private var selectedAcknowledgementPackage: URL?
        @State private var showBrowser = false

        public init() { }

        public var body: some View {
            KScrollableForm {
                KSection(header: TasktiveLocale.getText(.CONTRIBUTORS)) {
                    ForEach(acknowledgements?.contributors ?? [], id: \.self) { contributor in
                        Text(contributor.name)
                            .bold()
                            .ktakeWidthEagerly(alignment: .leading)
                        #if os(macOS)
                        if contributor != acknowledgements?.contributors.last {
                            Divider()
                        }
                        #endif
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                KSection(header: TasktiveLocale.getText(.PACKAGES)) {
                    ForEach(acknowledgements?.packages ?? [], id: \.self) { package in
                        Button(action: { selectedAcknowledgementPackage = package.url }) {
                            VStack(alignment: .leading) {
                                Text(package.name)
                                    .bold()
                                Text(package.url.absoluteString)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .ktakeWidthEagerly(alignment: .leading)
                            #if os(macOS)
                                .background(Color(nsColor: .separatorColor).opacity(0.01))
                            #endif
                        }
                        .buttonStyle(.plain)
                        #if os(macOS)
                        if package != acknowledgements?.packages.last {
                            Divider()
                        }
                        #endif
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .onChange(of: showBrowser, perform: { newValue in
                if !newValue {
                    selectedAcknowledgementPackage = nil
                }
            })
            .onChange(of: selectedAcknowledgementPackage, perform: { newValue in
                showBrowser = newValue != nil
                logger.info("selected acknowledgement package changed to \(newValue as Any)")
            })
            .inAppBrowserSUI(
                $selectedAcknowledgementPackage,
                fallbackURL: URL(staticString: "https://kamaal.io"),
                color: .accentColor
            )
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
    let contributors: [AcknowledgementContributor]
}

struct AcknowledgementContributor: Hashable, Codable {
    let name: String
    let contributions: Int
}

struct AcknowledgementPackage: Hashable, Codable {
    let name: String
    let url: URL
    let author: String
    let license: String?
}
