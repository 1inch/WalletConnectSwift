// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WalletConnectSwift",
    platforms: [
        .macOS(.v10_14), .iOS(.v11),
    ],
    products: [
        .library(
            name: "WalletConnectSwift",
            targets: ["WalletConnectSwift"])
    ],
    dependencies: [
        .package(name: "CryptoSwift", url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.0"),
        .package(name: "Starscream", url: "https://github.com/daltoniam/Starscream.git", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "WalletConnectSwift", 
            dependencies: ["CryptoSwift", "Starscream"],
            path: "Sources"),
        .testTarget(name: "WalletConnectSwiftTests", dependencies: ["WalletConnectSwift"], path: "Tests"),
    ]
)
