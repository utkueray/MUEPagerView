// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MUPager",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MUPager",
            targets: ["MUPager"])
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "MUPager",
            dependencies: ["SnapKit"]
        )
    ]
)
