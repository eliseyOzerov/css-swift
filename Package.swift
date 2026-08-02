// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swiftcss",
    platforms: [.iOS(.v18), .macOS(.v14), .tvOS(.v17), .visionOS(.v1)],
    products: [
        .library(name: "SwiftCSS", targets: ["SwiftCSS"]),
    ],
    targets: [
        .target(name: "SwiftCSS"),
        .testTarget(
            name: "SwiftCSSTests",
            dependencies: ["SwiftCSS"]
        ),
    ]
)
