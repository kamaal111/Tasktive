//
//  SupportAuthorScreen.swift
//
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import os.log
import SwiftUI
import SalmonUI
import ConfettiSwiftUI

@available(macOS 13.0, iOS 16.0, *)
private let logger = Logger(
    subsystem: "io.kamaal.SettingsUI",
    category: String(describing: SettingsUI.SupportAuthorScreen.self)
)

extension SettingsUI {
    @available(macOS 13.0, iOS 16.0, *)
    public struct SupportAuthorScreen: View {
        @EnvironmentObject private var store: Store

        @State private var confettiTimesRun = 0
        @State private var numberOfConfettis = 20
        @State private var confettiRepetitions = 0

        @Binding public var navigationPath: NavigationPath

        let handlePurchaseFailure: (_ error: Store.Errors) -> Void

        public init(navigationPath: Binding<NavigationPath>,
                    handlePurchaseFailure: @escaping (_ error: Error) -> Void) {
            self._navigationPath = navigationPath
            self.handlePurchaseFailure = handlePurchaseFailure
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
                            DonationsButton(donation: donation, action: handlePurchase(_:))
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
            .confettiCannon(counter: $confettiTimesRun, num: numberOfConfettis, repetitions: confettiRepetitions)
        }

        private func handlePurchase(_ donation: CustomProduct) {
            store.purchaseDonation(donation, completion: { result in
                switch result {
                case let .failure(failure):
                    handlePurchaseFailure(failure)
                    return
                case .success:
                    break
                }

                shootConfetti(for: donation)
            })
        }

        private func shootConfetti(for donation: CustomProduct) {
            let weight = donation.weight

            DispatchQueue.main.async {
                numberOfConfettis = (20 * weight)
                confettiRepetitions = weight < 1 ? 0 : (weight - 1)
                confettiTimesRun += 1
            }
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
