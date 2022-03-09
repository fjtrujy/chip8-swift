// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CHIP8",
    products: [
        .library(
            name: "CHIP8Emulator",
            targets: ["CHIP8"]),
    ], dependencies: [
        .package(name: "JavaScriptKit", url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "CHIP8",
            dependencies: ["JavaScriptKit"]),
        .testTarget(
            name: "CHIP8Tests",
            dependencies: ["CHIP8"]),
    ]
)
