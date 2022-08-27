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

extension SettingsUI {
    #if swift(>=5.7)
    @available(macOS 13.0, iOS 16.0, *)
    public struct SupportAuthorScreen: View {
        @Binding public var navigationPath: NavigationPath

        let handlePurchaseFailure: (_ error: Store.Errors) -> Void

        public init(navigationPath: Binding<NavigationPath>,
                    handlePurchaseFailure: @escaping (_ error: Error) -> Void) {
            self._navigationPath = navigationPath
            self.handlePurchaseFailure = handlePurchaseFailure
        }

        public var body: some View {
            SupportAuthorScreenView(
                handlePurchaseFailure: handlePurchaseFailure,
                navigateBack: { navigationPath.removeLast() }
            )
        }
    }
    #else
    public struct SupportAuthorScreen: View {
        @Environment(\.presentationMode) private var presentationMode

        let handlePurchaseFailure: (_ error: Store.Errors) -> Void

        public init(handlePurchaseFailure: @escaping (_ error: Error) -> Void) {
            self.handlePurchaseFailure = handlePurchaseFailure
        }

        public var body: some View {
            SupportAuthorScreenView(
                handlePurchaseFailure: handlePurchaseFailure,
                navigateBack: { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
    #endif

    private struct SupportAuthorScreenView: View {
        private let logger = Logger(
            subsystem: "io.kamaal.SettingsUI",
            category: "SupportAuthorScreenView"
        )

        @EnvironmentObject private var store: Store

        @State private var confettiTimesRun = 0
        @State private var numberOfConfettis = 20
        @State private var confettiRepetitions = 0

        let handlePurchaseFailure: (_ error: Store.Errors) -> Void
        let navigateBack: () -> Void

        var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack {
                    VStack {
                        if store.isLoading, !store.hasDonations {
                            KLoading()
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
                            KLoading()
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
                    navigateBack()
                case .success:
                    break
                }
            }
        }

        private func shootConfetti(for donation: CustomProduct) {
            let weight = donation.weight

            DispatchQueue.main.async {
                numberOfConfettis = (20 * weight)
                confettiRepetitions = weight < 1 ? 0 : (weight - 1)
                confettiTimesRun += 1
            }
        }
    }
}
