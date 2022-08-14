//
//  SupportAuthorScreen.swift
//
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import os.log
import SwiftUI
import SalmonUI

@available(macOS 13.0, iOS 16.0, *)
private let logger = Logger(
    subsystem: "io.kamaal.SettingsUI",
    category: String(describing: SettingsUI.SupportAuthorScreen.self)
)

extension SettingsUI {
    @available(macOS 13.0, iOS 16.0, *)
    public struct SupportAuthorScreen: View {
        @EnvironmentObject private var store: Store

        @Binding public var navigationPath: NavigationPath

        public init(navigationPath: Binding<NavigationPath>) {
            self._navigationPath = navigationPath
        }

        public var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack {
                    VStack {
                        if store.isLoading, !store.hasDonations {
                            LoadingView()
                                .ktakeSizeEagerly()
                        }
                        ForEach(store.donations) { donation in
                            DonationsButton(donation: donation, action: store.purchaseDonation(_:))
                                .padding(.vertical, 4)
                                .disabled(!store.canMakePayments)
                        }
                    }
                    if store.isPurchasing {
                        HStack {
                            LoadingView()
                            Text(NSLocalizedString("Purchasing", bundle: .module, comment: ""))
                                .font(.headline)
                                .bold()
                        }
                        .ktakeSizeEagerly()
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .ktakeSizeEagerly(alignment: .topLeading)
            .onAppear(perform: handleAppear)
        }

        private func handleAppear() {
            Task {
                let result = await store.requestProducts()
                switch result {
                case let .failure(failure):
                    let message = [
                        "failed to get donations",
                        "error='\(failure)'",
                    ].joined(separator: ";")
                    logger.error("\(message)")
                    // Navigate back
                    navigationPath.removeLast()
                case .success:
                    break
                }
            }
        }
    }
}
