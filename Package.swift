// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CHIP8",
    products: [
        .library(
            name: "CHIP8Emulator",
            type: .dynamic,
            targets: ["CHIP8", "CHIP8Roms"]),
    ], dependencies: [
    ],
    targets: [
        .target(
            name: "CHIP8",
            dependencies: []),
        .target(
            name: "CHIP8Roms",
            dependencies: []),
        .testTarget(
            name: "CHIP8Tests",
            dependencies: ["CHIP8"]),
    ]
)
