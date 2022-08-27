// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingsUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "SettingsUI",
            targets: ["SettingsUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/SalmonUI.git", "5.0.2" ..< "6.0.0"),
        .package(url: "https://github.com/kamaal111/GitHubAPI.git", "0.1.2" ..< "0.2.0"),
        .package(url: "https://github.com/kamaal111/StoreAPIClient.git", "0.1.1" ..< "0.2.0"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", "1.0.1" ..< "1.0.2"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                .product(name: "StoreAPI", package: "StoreAPIClient"),
                "SalmonUI",
                "GitHubAPI",
                "ConfettiSwiftUI",
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
