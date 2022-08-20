//
//  AppLogo.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import SwiftUI
import ShrimpExtensions

struct AppLogo: View {
    let size: CGSize
    let curvedCornersSize: CGFloat?
    let backgroundColor: Color?

    var body: some View {
        ZStack {
            if let backgroundColor = backgroundColor {
                backgroundColor
            }
        }
        .frame(width: size.width, height: size.height)
        .cornerRadius(curvedCornersSize ?? 0)
    }
}

struct AppLogo_Previews: PreviewProvider {
    static var previews: some View {
        AppLogo(size: .squared(150), curvedCornersSize: 16, backgroundColor: .black)
            .padding(.all, .large)
            .previewLayout(.sizeThatFits)
    }
}
