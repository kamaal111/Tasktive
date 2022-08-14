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

        public let defaultColor: Color
        public let onColorSelect: (_ color: AppColor) -> Void

        public init(defaultColor: Color, onColorSelect: @escaping (_: AppColor) -> Void) {
            self.defaultColor = defaultColor
            self.onColorSelect = onColorSelect
        }

        public var body: some View {
            ScrollView(.vertical, showsIndicators: true) {
                SectionView(header: NSLocalizedString("Colors", bundle: .module, comment: "")) {
                    ForEach(AppColor.defaultColors) { color in
                        if let variants = color.variants {
                            RowViewColorButton(
                                action: { onColorSelect(color) },
                                label: color.title,
                                color: colorScheme == .dark ? variants.dark.color : variants.light.color
                            )
                        } else {
                            RowViewColorButton(
                                action: { onColorSelect(color) },
                                label: color.title,
                                color: defaultColor
                            )
                        }
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
        }
    }
}
