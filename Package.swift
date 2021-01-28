// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleTwoWayBinding",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "SimpleTwoWayBinding",
            targets: ["SimpleTwoWayBinding"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "SimpleTwoWayBinding",
            dependencies: []),
        .testTarget(
            name: "SimpleTwoWayBindingTests",
            dependencies: ["SimpleTwoWayBinding"]),
    ]
)
