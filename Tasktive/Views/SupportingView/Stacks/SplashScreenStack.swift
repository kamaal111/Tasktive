//
//  SplashScreenStack.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 20/08/2022.
//

import SwiftUI
import SalmonUI
import ShrimpExtensions

struct SplashScreenStack<Content: View>: View {
    @State private var isShown = true

    let enabled: Bool
    let content: Content

    init(enabled: Bool, @ViewBuilder content: () -> Content) {
        self.enabled = enabled
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if enabled, isShown {
                KJustStack {
                    #if os(iOS)
                    Color(.systemBackground)
                    #endif
                    Image("Logo")
                        .size(.squared(260))
                        .padding(.bottom, 12)
                }
                .onAppear(perform: {
                    withAnimation {
                        isShown = false
                    }
                })
            }
        }
    }
}

struct SplashScreenStack_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenStack(enabled: DeviceModel.deviceType != .mac) {
            Text("Content")
        }
    }
}
