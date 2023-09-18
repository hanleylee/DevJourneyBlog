// swift-tools-version:5.5

import PackageDescription

let isLocalDebug = true

let package = Package(
    name: "DevJourneyBlog",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "DevJourneyBlog",
            targets: ["DevJourneyBlog"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
//        .package(name: "ReadingTimePublishPlugin", url: "https://github.com/alexito4/ReadingTimePublishPlugin", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "DevJourneyBlog",
            dependencies: [
                "Publish",
                "Splash",
//                "ReadingTimePublishPlugin",
            ],
            path: "Sources",
            resources: [
                .process("Resources/Markdown")
            ]
        )
    ]
)

if isLocalDebug {
    package.dependencies += [
        .package(path: "../Publish"),
    ]
} else {
    package.dependencies += [
        .package(url: "https://github.com/hanleylee/Publish", .branchItem("master")),
    ]
}
