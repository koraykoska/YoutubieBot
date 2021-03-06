// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "YoutubieBot",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),

        // Kitura HTTP Client
        .package(name: "SwiftyRequest", url: "https://github.com/IBM-Swift/SwiftyRequest.git", from: "3.1.0"),

        // TelegramBot
        .package(name: "TelegramBot", url: "https://github.com/Boilertalk/TelegramBot.swift.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "TelegramBot", package: "TelegramBot"),
                .product(name: "TelegramBotVapor", package: "TelegramBot"),
                .product(name: "TelegramBotPromiseKit", package: "TelegramBot"),
                .product(name: "SwiftyRequest", package: "SwiftyRequest"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
