//
//  SupportAuthorScreen.swift
//
//
//  Created by Kamaal M Farah on 13/08/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    public struct SupportAuthorScreen: View {
        @EnvironmentObject private var store: Store

        public init() { }

        public var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack {
                    VStack {
                        if store.isLoading, !store.hasDonations {
                            LoadingView()
                                .ktakeSizeEagerly()
                        }
                        ForEach(store.donations) { donation in
                            Text(donation.displayName)
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
            }
            .ktakeSizeEagerly(alignment: .topLeading)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
