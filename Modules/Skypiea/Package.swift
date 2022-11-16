// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Skypiea",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Skypiea",
            targets: ["Skypiea"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ICloutKit.git", "3.0.0" ..< "4.0.0"),
        .package(url: "https://github.com/kamaal111/ShrimpExtensions.git", "2.6.0" ..< "3.0.0"),
        .package(url: "https://github.com/kamaal111/Logster.git", "1.1.0" ..< "2.0.0"),
        .package(path: "../SharedModels"),
    ],
    targets: [
        .target(
            name: "Skypiea",
            dependencies: [
                "ICloutKit",
                "ShrimpExtensions",
                "Logster",
                "SharedModels",
            ]
        ),
        .testTarget(
            name: "SkypieaTests",
            dependencies: ["Skypiea"]
        ),
    ]
)
