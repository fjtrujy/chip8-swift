// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CHIP8",
    dependencies: [
        .package(name: "SDL2", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "CHIP8",
            dependencies: []),
        .target(
            name: "CHIP8App",
            dependencies: ["SDL2", "CHIP8"]),
        .testTarget(
            name: "CHIP8Tests",
            dependencies: ["CHIP8"]),
    ]
)
