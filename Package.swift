// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logma",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Logma",
            targets: ["Logma"]
        ),
        .library(
            name: "Logmo",
            targets: ["Logmo"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Logma",
            dependencies: []
        ),
        .target(
            name: "Logmo",
            dependencies: [
                "Logma"
            ]
        )
    ]
)
