// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Skypiea",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "Skypiea",
            targets: ["Skypiea"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ICloutKit.git", "3.0.0" ..< "4.0.0"),
        .package(url: "https://github.com/kamaal111/ShrimpExtensions.git", "2.6.0" ..< "3.0.0"),
    ],
    targets: [
        .target(
            name: "Skypiea",
            dependencies: [
                "ICloutKit",
                "ShrimpExtensions",
            ]
        ),
        .testTarget(
            name: "SkypieaTests",
            dependencies: ["Skypiea"]
        ),
    ]
)
