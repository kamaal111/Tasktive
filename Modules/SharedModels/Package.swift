// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedModels",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "SharedModels",
            targets: ["SharedModels"]
        ),
    ],
    dependencies: [
        .package(path: "../Environment"),
        .package(path: "../TasktiveLocale"),
    ],
    targets: [
        .target(
            name: "SharedModels",
            dependencies: [
                "Environment",
                "TasktiveLocale",
            ]
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"]
        ),
    ]
)
