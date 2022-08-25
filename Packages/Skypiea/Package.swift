// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Skypiea",
    products: [
        .library(
            name: "Skypiea",
            targets: ["Skypiea"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Skypiea",
            dependencies: []
        ),
        .testTarget(
            name: "SkypieaTests",
            dependencies: ["Skypiea"]
        ),
    ]
)
