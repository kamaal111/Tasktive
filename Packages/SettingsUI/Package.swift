// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingsUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "SettingsUI",
            targets: ["SettingsUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/SalmonUI.git", "4.0.0" ..< "5.0.0"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                "SalmonUI",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "SettingsUITests",
            dependencies: ["SettingsUI"]
        ),
    ]
)
