// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatedImageGenerator",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DatedImage",
            targets: ["DatedImage"]),
        .plugin(
            name: "DatedImageGenerator",
            targets: ["DatedImageGenerator"]),
        .plugin(
            name: "DatedImageGeneratorCommand",
            targets: ["DatedImageGeneratorCommand"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/baguio/XcodeIssueReporting", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Implementation
        .executableTarget(
            name: "DatedImageGeneratorExecutable",
            dependencies:  [
                "DatedImage",
                .product(name: "XcodeIssueReporting", package: "XcodeIssueReporting"),
            ],
            path: "Sources/DatedImageGeneratorExecutable"
        ),
        .target(name: "DatedImage",
                dependencies:  [],
                path: "Sources/DatedImage"),
        // Interface
        .plugin(
            name: "DatedImageGenerator",
            capability: .buildTool(),
            dependencies: [
                .target(name: "DatedImageGeneratorExecutable")
            ]
        ),
        .plugin(
            name: "DatedImageGeneratorCommand",
            capability: .command(
                intent: .custom(verb: "GenerateCode", description: "Generates dated images on a one-time only basis"),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates code to be checked into version control")
                ]
            ),
            dependencies: [
                .target(name: "DatedImageGeneratorExecutable")
            ]
        ),
        // Tests
        .testTarget(
            name: "DatedImageGeneratorTests",
            dependencies: ["DatedImageGeneratorExecutable"]),
    ]
)
