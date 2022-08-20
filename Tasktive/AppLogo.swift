//
//  AppLogo.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import SwiftUI
import SalmonUI
import ShrimpExtensions

struct AppLogo: View {
    let size: CGFloat
    let curvedCornersSize: CGFloat?
    let backgroundColor: Color?
    let gradientColor: Color?
    let paperColor: Color
    let primaryColor: Color
    let lineColor: Color

    var body: some View {
        ZStack {
            background
            Rectangle()
                .foregroundColor(paperColor)
                .frame(width: paperSize.width, height: paperSize.height)
                .cornerRadius(size / 15)
            VStack {
                ForEach(0 ..< 3, id: \.self) { _ in
                    HStack(spacing: circleSize.width / 2) {
                        Circle()
                            .frame(width: circleSize.width, height: circleSize.height)
                            .foregroundColor(primaryColor)
                        Rectangle()
                            .foregroundColor(lineColor)
                            .frame(height: circleSize.height / 8)
                    }
                    .padding(.vertical, size / 30)
                    .padding(.horizontal, paperSize.width / 2.5)
                }
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize ?? 0)
    }

    private var background: some View {
        KJustStack {
            if let backgroundColor = backgroundColor {
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, gradientColor ?? backgroundColor]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            }
        }
    }

    private var circleSize: CGSize {
        .squared(size / 20)
    }

    private var paperSize: CGSize {
        .init(width: size / 1.6, height: size / 1.3)
    }
}

struct AppLogo_Previews: PreviewProvider {
    static var previews: some View {
        AppLogo(
            size: 150,
            curvedCornersSize: 16,
            backgroundColor: .AccentColor,
            gradientColor: .black,
            paperColor: .white,
            primaryColor: .AccentColor,
            lineColor: .gray
        )
        .padding(.all, .large)
        .previewLayout(.sizeThatFits)
    }
}
