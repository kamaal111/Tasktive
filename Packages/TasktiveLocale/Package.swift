// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TasktiveLocale",
    defaultLocalization: "en",
    products: [
        .library(
            name: "TasktiveLocale",
            targets: ["TasktiveLocale"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TasktiveLocale",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "TasktiveLocaleTests",
            dependencies: ["TasktiveLocale"]
        ),
    ]
)
