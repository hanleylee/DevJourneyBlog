// swift-tools-version:5.5

/**
 *  Publish
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import PackageDescription

let settings: [SwiftSetting]
#if os(Linux)
    settings = [.define("OS_LINUX")]
#elseif os(macOS)
    settings = [.define("OS_MAC")]
#endif

let package = Package(
    name: "Publish",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "Publish", targets: ["Publish"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-markdown.git",
            .branch("main")
        ),
        .package(
            name: "Plot",
            url: "https://github.com/johnsundell/plot.git",
            from: "0.14.0"
        ),
        .package(
            name: "Files",
            url: "https://github.com/johnsundell/files.git",
            from: "4.2.0"
        ),
        .package(
            name: "Codextended",
            url: "https://github.com/johnsundell/codextended.git",
            from: "0.3.0"
        ),
        .package(
            name: "ShellOut",
            url: "https://github.com/johnsundell/shellout.git",
            from: "2.3.0"
        ),
        .package(
            name: "Sweep",
            url: "https://github.com/johnsundell/sweep.git",
            from: "0.4.0"
        ),
        .package(
            name: "CollectionConcurrencyKit",
            url: "https://github.com/johnsundell/collectionConcurrencyKit.git",
            from: "0.2.0"
        )
    ],
    targets: [
        .target(
            name: "Publish",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                "Plot",
                "Files",
                "Codextended",
                "ShellOut",
                "Sweep",
                "CollectionConcurrencyKit"
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "PublishTests",
            dependencies: ["Publish"]
        )
    ]
)
