//
//  AppLogoColorSelector.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

#if DEBUG && swift(>=5.7)
import SwiftUI

struct AppLogoColorSelector: View {
    @Binding var color: Color

    let title: String

    private let circleSize: CGFloat = 20

    var body: some View {
        AppLogoColorFormRow(title: title) {
            HStack {
                ForEach(PLAYGROUND_SELECTABLE_COLORS, id: \.self) { color in
                    Button(action: { withAnimation { self.color = color } }) {
                        ZStack {
                            if color == self.color {
                                Circle()
                                    .frame(width: circleSize * 1.2, height: circleSize * 1.2)
                                    .foregroundColor(.accentColor)
                            }
                            Circle()
                                .frame(width: circleSize, height: circleSize)
                                .foregroundColor(color)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct AppLogoColorSelector_Previews: PreviewProvider {
    static var previews: some View {
        AppLogoColorSelector(color: .constant(.red), title: "Title")
    }
}
#endif
