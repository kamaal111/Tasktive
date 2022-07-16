// swift-tools-version: 5.7
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
            dependencies: []
        ),
        .testTarget(
            name: "TasktiveLocaleTests",
            dependencies: ["TasktiveLocale"]
        ),
    ]
)
