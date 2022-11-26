//
//  LogsScreen.swift
//
//
//  Created by Kamaal M Farah on 22/09/2022.
//

import SwiftUI
import Logster
import SalmonUI
import TasktiveLocale

extension SettingsUI {
    public struct LogsScreen: View {
        @State private var logs: [HoldedLog] = []
        @State private var selectedLog: HoldedLog?
        @State private var showSelectedLogSheet = false

        let navigate: (_ screen: SettingsScreens) -> Void

        public init(navigate: @escaping (_ screen: SettingsScreens) -> Void) {
            self.navigate = navigate
        }

        public var body: some View {
            KScrollableForm {
                KSection {
                    ForEach(logs, id: \.self) { item in
                        Button(action: { selectedLog = item }) {
                            HStack(spacing: 8) {
                                Text(item.label)
                                    .foregroundColor(item.type.color)
                                Text(item.message)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            .ktakeWidthEagerly(alignment: .leading)
                            #if os(macOS)
                                .background(Color(nsColor: .separatorColor).opacity(0.01))
                            #endif
                        }
                        .buttonStyle(.plain)
                        #if os(macOS)
                        if item != logs.last {
                            Divider()
                        }
                        #endif
                    }
                }
                #if os(macOS)
                .padding(.all, 16)
                #endif
            }
            .ktakeSizeEagerly(alignment: .topLeading)
            .onAppear {
                Task { logs = await LogHolder.shared.logs.reversed() }
            }
            .onChange(of: selectedLog) { newValue in
                showSelectedLogSheet = newValue != nil
            }
            .onChange(of: showSelectedLogSheet, perform: { newValue in
                if !newValue {
                    closeSheet()
                }
            })
            .sheet(isPresented: $showSelectedLogSheet) {
                SelectedLogSheet(log: selectedLog, closeSheet: closeSheet, navigateToFeedbackScreen: {
                    let selectedLog = self.selectedLog
                    closeSheet()
                    if let selectedLog {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let predefinedDescription = """
                            # Reported log

                            label: \(selectedLog.label)
                            type: \(selectedLog.type.rawValue)
                            message: \(selectedLog.message)


                            """
                            let feedback = SettingsScreens.feedback(
                                style: .bug,
                                predefinedDescription: predefinedDescription
                            )
                            navigate(feedback)
                        }
                    }
                })
            }
        }

        func closeSheet() {
            selectedLog = nil
        }
    }

    struct SelectedLogSheet: View {
        let log: HoldedLog?
        let closeSheet: () -> Void
        let navigateToFeedbackScreen: () -> Void

        var body: some View {
            KSheetStack(
                title: TasktiveLocale.getText(.LOG),
                leadingNavigationButton: {
                    Button(action: closeSheet) {
                        Text(TasktiveLocale.getText(.CLOSE))
                            .bold()
                    }
                },
                trailingNavigationButton: { Text("") }
            ) {
                VStack(alignment: .leading) {
                    if let log {
                        Text(log.label)
                            .font(.headline)
                            .foregroundColor(log.type.color)
                        Text(log.message)
                            .foregroundColor(.primary)
                        if [HoldedLog.LogTypes.error, .warning].contains(log.type) {
                            Button(action: { navigateToFeedbackScreen() }) {
                                HStack {
                                    Image(systemName: "ant")
                                    Text(TasktiveLocale.getText(.REPORT_BUG))
                                        .bold()
                                }
                                .padding(.vertical, 16)
                                .ktakeWidthEagerly()
                                .background(log.type.color)
                                .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 16)
                .ktakeSizeEagerly(alignment: .topLeading)
            }
        }
    }
}
