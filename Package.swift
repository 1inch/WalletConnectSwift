// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "WalletConnectSwift",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "WalletConnectSwift",
            targets: ["WalletConnectSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.7.2"))
    ],
    targets: [
        .target(
            name: "WalletConnectSwift", 
            dependencies: ["CryptoSwift"],
            path: "Sources"),
        .testTarget(name: "WalletConnectSwiftTests", dependencies: ["WalletConnectSwift"], path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
