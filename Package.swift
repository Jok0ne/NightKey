// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NightKey",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NightKey",
            path: "Sources/NightKey"
        )
    ]
)
