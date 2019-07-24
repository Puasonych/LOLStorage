// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RStorage",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "RStorage", targets: ["RStorage"])
    ],
    dependencies: [],
    targets: [
        .target(name: "RStorage", path: "RStorage")
    ],
    swiftLanguageVersions: [.v5]
)
