// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BearBasic",
    platforms: [
        .iOS(.v18),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BearBasic",
            targets: ["BearBasic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.3")),
        .package(url: "https://gitee.com/cellgit/Result.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "BearBasic",
            dependencies: ["Moya", "Result"]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .testTarget(
            name: "BearBasicTests",
            dependencies: ["BearBasic"]
        ),
    ]
)
