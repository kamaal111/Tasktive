//
//  FeedbackScreen.swift
//
//
//  Created by Kamaal M Farah on 06/08/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    public struct FeedbackScreen: View {
        @Environment(\.colorScheme) private var colorScheme

        @StateObject private var viewModel = ViewModel()

        public let style: FeedbackStyles

        public init(style: FeedbackStyles) {
            self.style = style
        }

        public var body: some View {
            VStack {
                KFloatingTextField(
                    text: $viewModel.title,
                    title: NSLocalizedString("Title", bundle: .module, comment: "")
                )
                KTextView(
                    text: $viewModel.description,
                    title: NSLocalizedString("Description", bundle: .module, comment: "")
                )
                Button(action: onSendPress) {
                    Text(NSLocalizedString("Send", bundle: .module, comment: ""))
                        .font(.headline)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.vertical, 4)
                        .ktakeWidthEagerly()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.disableSubmit)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .navigationTitle(Text(style.title))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }

        private func onSendPress() {
            Task {
                await viewModel.submit()
            }
        }
    }
}

extension SettingsUI.FeedbackScreen {
    final class ViewModel: ObservableObject {
        @Published var title = ""
        @Published var description = ""
        @Published var loading = false

        init() { }

        var disableSubmit: Bool {
            loading || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func submit() async {
            await withLoading(completion: {
                #warning("Handle submit logic")
            })
        }

        private func withLoading<T>(completion: () -> T) async -> T {
            await setLoading(true)
            let result = completion()
            await setLoading(false)
            return result
        }

        @MainActor
        private func setLoading(_ state: Bool) {
            loading = state
        }
    }
}
