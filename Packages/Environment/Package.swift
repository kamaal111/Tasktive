// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Environment",
    products: [
        .library(
            name: "Environment",
            targets: ["Environment"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Environment",
            dependencies: []
        ),
        .testTarget(
            name: "EnvironmentTests",
            dependencies: ["Environment"]
        ),
    ]
)
