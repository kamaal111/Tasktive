//
//  DeviceShakeViewModifier.swift
//  Tasktive
//
//  Created by Kamaal M Farah on 17/08/2022.
//

#if canImport(UIKit)
import SwiftUI

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with _: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}

private struct DeviceShakeViewModifier: ViewModifier {
    @State private var isVisible = false

    let onlyWhenVisible: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                isVisible = true
            })
            .onDisappear(perform: {
                isVisible = false
            })
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake), perform: { _ in
                if isVisible || !onlyWhenVisible {
                    action()
                }
            })
    }
}

extension View {
    func onShake(onlyWhenVisible: Bool = true, perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(onlyWhenVisible: onlyWhenVisible, action: action))
    }
}
#endif
