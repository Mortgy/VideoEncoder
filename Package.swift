// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoEncoder",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "VideoEncoder",
            targets: ["VideoEncoder"]),
    ],
    targets: [
        .target(
            name: "VideoEncoder",
            dependencies: []),
        .testTarget(
            name: "VideoEncoderTests",
            dependencies: ["VideoEncoder"]),
    ]
)

