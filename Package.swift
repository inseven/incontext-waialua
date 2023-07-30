// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ic3",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: "Dependencies/Stencil"),
        .package(path: "Dependencies/Tilt"),
        .package(url: "https://github.com/BiosTheoretikos/Ogma.git", from: "0.1.3"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.2.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.4"),  // Good for unknown?
        .package(url: "https://github.com/johnfairh/swift-sass.git", from: "1.7.0"),
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),  // Good for known structures
        .package(url: "https://github.com/jwells89/Titlecaser.git", from: "1.0.0"),
        .package(url: "https://github.com/objecthub/swift-markdownkit.git", from: "1.1.7"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ic3",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "DartSass", package: "swift-sass"),
                .product(name: "Ink", package: "ink"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "MarkdownKit", package: "swift-markdownkit"),
                .product(name: "Ogma", package: "Ogma"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Tilt", package: "Tilt"),
                .product(name: "Titlecaser", package: "Titlecaser"),
                .product(name: "Yaml", package: "YamlSwift"),
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources"),
        .testTarget(
            name: "ic3tests",
            dependencies: ["ic3"]),
    ]
)

// TODO: Consider whether any of these really make sense.
let swiftSettings: [SwiftSetting] = [
    // -enable-bare-slash-regex becomes
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    // -warn-concurrency becomes
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-enable-actor-data-race-checks"],
        .when(configuration: .debug)),
]

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
