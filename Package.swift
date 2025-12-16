// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "dbQuery",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "DBQuery", targets: ["DBQuery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0"),
    ],
	targets: [
		.target(
			name: "DBQuery",
			dependencies: [
				.product(name: "Fluent", package: "fluent"),
				.product(name: "SQLKit", package: "sql-kit"),
			],
			swiftSettings: swiftSettings
		),
	]
)

/// Swift compiler settings for Release configuration.
var swiftSettings: [SwiftSetting] { [
	// "ExistentialAny" is an option that makes the use of the `any` keyword for existential types `required`
	.enableUpcomingFeature("ExistentialAny")
] }
