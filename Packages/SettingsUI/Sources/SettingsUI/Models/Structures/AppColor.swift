//
//  AppColor.swift
//
//
//  Created by Kamaal M Farah on 07/08/2022.
//

import SwiftUI
import TasktiveLocale

private let RGB_MAX = 255.0

public struct AppColor: Hashable, Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let variants: RGBVariants?

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

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
        self.variants = nil
    }

    public static let defaultColors: [AppColor] = [
        .init(
            id: UUID(uuidString: "1f6f9ac4-1ca6-4f77-880b-01580881a9b4")!,
            title: TasktiveLocale.getText(.DEFAULT)
        ),
        .init(
            id: UUID(uuidString: "57547f06-2d3e-4f3d-a639-59c13a5433bb")!,
            title: TasktiveLocale.getText(.TEAL),
            variants: .init(light: RGB(red: 89, green: 173, blue: 196), dark: RGB(red: 105, green: 196, blue: 220))
        ),
        .init(
            id: UUID(uuidString: "c5b39ff8-091a-4c46-a067-0bc5b1df4caf")!,
            title: TasktiveLocale.getText(.PURPLE),
            variants: .init(light: RGB(red: 175, green: 82, blue: 222), dark: RGB(red: 191, green: 90, blue: 242))
        ),
        .init(
            id: UUID(uuidString: "1d2a4931-f1c2-42bf-b097-27908e1fa39a")!,
            title: TasktiveLocale.getText(.GREEN),
            variants: .init(light: RGB(red: 0, green: 191, blue: 0), dark: RGB(red: 50, green: 215, blue: 75))
        ),
        .init(
            id: UUID(uuidString: "bab5b0eb-d672-4ece-bdc7-4453daf64379")!,
            title: TasktiveLocale.getText(.YELLOW),
            variants: .init(light: RGB(red: 255, green: 204, blue: 0), dark: RGB(red: 255, green: 214, blue: 10))
        ),
        .init(
            id: UUID(uuidString: "7a664baf-b0ac-4764-86b4-3860773fe9c4")!,
            title: TasktiveLocale.getText(.PINK),
            variants: .init(light: RGB(red: 255, green: 44, blue: 85), dark: RGB(red: 255, green: 55, blue: 95))
        ),
        .init(
            id: UUID(uuidString: "ab3aa7c5-c9e3-45a9-a2ef-f82603f11eab")!,
            title: TasktiveLocale.getText(.ORANGE),
            variants: .init(light: RGB(red: 255, green: 69, blue: 58), dark: RGB(red: 255, green: 149, blue: 0))
        ),
        .init(
            id: UUID(uuidString: "0125142b-4a50-4f7f-b02c-a4963a6e4633")!,
            title: TasktiveLocale.getText(.RED),
            variants: .init(light: RGB(red: 255, green: 59, blue: 48), dark: RGB(red: 255, green: 69, blue: 58))
        ),
        .init(
            id: UUID(uuidString: "eb82e779-a7ba-4c75-a6e2-53d35332b940")!,
            title: TasktiveLocale.getText(.BLUE),
            variants: .init(light: RGB(red: 0, green: 122, blue: 255), dark: RGB(red: 10, green: 132, blue: 255))
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
