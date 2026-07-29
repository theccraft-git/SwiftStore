// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SwiftStore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SwiftStore", targets: ["SwiftStore"])
    ],
    targets: [
        .target(
            name: "SwiftStore",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
