import PackageDescription

let package = Package(
    name: "RStorage",
    platforms: [.iOS(.v12)],
    swiftLanguageVersions: [.v5]
    products: [
        .library(name: "RStorage", targets: ["RStorage"])
    ],
    dependencies: [],
    targets: [
        .target(name: "RStorage")
    ]
)
