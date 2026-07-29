// swift-tools-version:5.8
// SwiftStore
import PackageDescription

let package = Package(
    name: "SwiftStore",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "SwiftStoreCore", targets: ["SwiftStoreCore"]),
    ],
    targets: [
        .target(
            name: "SwiftStoreCore",
            path: "Sources/SwiftStoreCore"
        ),
        .testTarget(
            name: "SwiftStoreCoreTests",
            dependencies: ["SwiftStoreCore"],
            path: "Tests/SwiftStoreCoreTests"
        )
    ]
)
