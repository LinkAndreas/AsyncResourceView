// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AsyncResourceView",
    products: [
        .library(
            name: "AsyncResourceView",
            targets: ["AsyncResourceView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncResourceView",
            dependencies: []
        ),
        .testTarget(
            name: "AsyncResourceViewTests",
            dependencies: ["AsyncResourceView"]
        ),
    ]
)
