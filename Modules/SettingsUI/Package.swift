// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SettingsUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
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
        .package(url: "https://github.com/kamaal111/ShrimpExtensions.git", "2.6.0" ..< "3.0.0"),
        .package(url: "https://github.com/kamaal111/InAppBrowserSUI.git", "1.0.0" ..< "2.0.0"),
        .package(path: "../Environment"),
        .package(path: "../Logster"),
        .package(path: "../TasktiveLocale"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                .product(name: "StoreAPI", package: "StoreAPIClient"),
                "SalmonUI",
                "GitHubAPI",
                "ConfettiSwiftUI",
                "ShrimpExtensions",
                "InAppBrowserSUI",
                "Environment",
                "Logster",
                "TasktiveLocale",
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
