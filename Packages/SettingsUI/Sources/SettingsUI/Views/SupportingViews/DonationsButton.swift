//
//  DonationsButton.swift
//
//
//  Created by Kamaal M Farah on 14/08/2022.
//

import SwiftUI
import TasktiveLocale

struct DonationsButton: View {
    let donation: CustomProduct
    let action: (_ donation: CustomProduct) -> Void

    var body: some View {
        Button(action: { action(donation) }) {
            HStack {
                Text(donation.emoji)
                VStack(alignment: .center) {
                    Text(TasktiveLocale.getText(.BUY_ME_A_TEXT, with: [donation.displayName]).uppercased())
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(donation.description.uppercased())
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(donation.displayPrice)
                    .bold()
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.primary.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct DonationsButton_Previews: PreviewProvider {
    static var previews: some View {
        DonationsButton(
            donation: .init(
                id: "io.kamaal.Tasktivity.donation.Soda",
                emoji: "🥤",
                weight: 0,
                displayName: "Soda",
                displayPrice: "$0.99",
                price: 0.99,
                description: "Support development (tier 1)"
            ),
            action: { _ in }
        )
    }
}
