//
//  AppColor.swift
//
//
//  Created by Kamaal M Farah on 07/08/2022.
//

import SwiftUI

private let RGB_MAX = 255.0

public struct AppColor: Hashable, Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let variants: RGBVariants

    public init?(id: UUID, title: String, hexString: (light: String, dark: String)) {
        guard let lightRGB = Self.hexToRGB(hexString.light),
              let darkRGB = Self.hexToRGB(hexString.dark) else { return nil }

        self.init(id: id, title: title, variants: .init(
            light: lightRGB,
            dark: darkRGB
        ))
    }

    public init(id: UUID, title: String, variants: RGBVariants) {
        self.id = id
        self.title = title
        self.variants = variants
    }

    public static let defaultColors: [AppColor] = [
        .init(
            id: UUID(uuidString: "57547f06-2d3e-4f3d-a639-59c13a5433bb")!,
            title: NSLocalizedString("Teal", bundle: .module, comment: ""),
            variants: .init(light: RGB(red: 89, green: 173, blue: 196), dark: RGB(red: 105, green: 196, blue: 220))
        ),
    ]

    private static func hexToRGB(_ hex: String) -> RGB? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 else { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        return RGB(
            red: Double((rgbValue & 0xFF0000) >> 16),
            green: Double((rgbValue & 0x00FF00) >> 8),
            blue: Double(rgbValue & 0x0000FF)
        )
    }
}

public struct RGB: Hashable, Codable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public var color: Color {
        Color(red: red / RGB_MAX, green: green / RGB_MAX, blue: blue / RGB_MAX)
    }
}

public struct RGBVariants: Hashable, Codable {
    public let light: RGB
    public let dark: RGB

    public init(light: RGB, dark: RGB) {
        self.light = light
        self.dark = dark
    }
}
