// swift-tools-version: 6.0

import PackageDescription
import Foundation

let commandLineToolsFrameworkPath = "/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
let commandLineToolsLibraryPath = "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"

let testSwiftSettings: [SwiftSetting]
let testLinkerSettings: [LinkerSetting]

if FileManager.default.fileExists(atPath: commandLineToolsFrameworkPath) {
    testSwiftSettings = [
        .unsafeFlags([
            "-F",
            commandLineToolsFrameworkPath
        ])
    ]
    testLinkerSettings = [
        .unsafeFlags([
            "-F",
            commandLineToolsFrameworkPath,
            "-Xlinker",
            "-rpath",
            "-Xlinker",
            commandLineToolsFrameworkPath,
            "-Xlinker",
            "-rpath",
            "-Xlinker",
            commandLineToolsLibraryPath
        ])
    ]
} else {
    testSwiftSettings = []
    testLinkerSettings = []
}

let package = Package(
    name: "RealityCaptureKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "RealityCaptureKit",
            targets: ["RealityCaptureKit"]
        )
    ],
    targets: [
        .target(
            name: "RealityCaptureKit"
        ),
        .testTarget(
            name: "RealityCaptureKitTests",
            dependencies: ["RealityCaptureKit"],
            swiftSettings: testSwiftSettings,
            linkerSettings: testLinkerSettings
        )
    ]
)
