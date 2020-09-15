// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CHIP8",
    products: [
        .library(
            name: "CHIP8Emulator",
            targets: ["CHIP8FE", "CHIP8", "CHIP8Roms"]),
    ], dependencies: [
        .package(name: "SDL2", url: "https://github.com/fjtrujy/SwiftSDL2.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "CHIP8",
            dependencies: []),
        .target(
            name: "CHIP8Roms",
            dependencies: []),
        .target(
            name: "CHIP8FE",
            dependencies: ["SDL2", "CHIP8"]),
        .target(
            name: "CHIP8App",
            dependencies: ["CHIP8FE", "CHIP8Roms"]),
        .testTarget(
            name: "CHIP8Tests",
            dependencies: ["CHIP8"]),
    ]
)
