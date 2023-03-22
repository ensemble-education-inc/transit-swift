// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Transit",
    platforms: [
        .iOS(.v16),
				.macOS(.v13)
    ],
    products: [
        .library(name: "Transit", targets: ["Transit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4")
    ],
    targets: [
        .target(
            name: "Transit",
            dependencies: [
              .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "TransitTests",
            dependencies: ["Transit"]
        ),
    ]
)
