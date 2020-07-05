// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v10),
        .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ragzy15/PublisherKit", from: "4.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "NetworkKit",
            dependencies: ["PublisherKit"]),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]),
    ]
)
