//
//  AppColorScreen.swift
//
//
//  Created by Kamaal M Farah on 07/08/2022.
//

import SwiftUI
import SalmonUI

extension SettingsUI {
    @available(macOS 12.0, *)
    public struct AppColorScreen: View {
        @Environment(\.colorScheme) private var colorScheme

        public let onColorSelect: (_ color: AppColor) -> Void

        public init(onColorSelect: @escaping (_: AppColor) -> Void) {
            self.onColorSelect = onColorSelect
        }

        public var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                SectionView(header: NSLocalizedString("Colors", bundle: .module, comment: "")) {
                    ForEach(AppColor.defaultColors) { color in
                        RowViewColorButton(
                            action: { onColorSelect(color) },
                            label: color.title,
                            color: colorScheme == .dark ? color.variants.dark.color : color.variants.light.color
                        )
                        #if os(macOS)
                        if color != AppColor.defaultColors.last {
                            Divider()
                        }
                        #endif
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .ktakeSizeEagerly(alignment: .topLeading)
            .navigationTitle(Text(NSLocalizedString("App colors", bundle: .module, comment: "")))
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
