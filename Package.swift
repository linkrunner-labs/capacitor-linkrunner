// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorLinkrunner",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorLinkrunner",
            targets: ["LinkrunnerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        .package(url: "https://github.com/linkrunner-labs/linkrunner-ios.git", from: "3.10.0")
    ],
    targets: [
        .target(
            name: "LinkrunnerPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "LinkrunnerKit", package: "linkrunner-ios")
            ],
            path: "ios/Sources/LinkrunnerPlugin"),
        .testTarget(
            name: "LinkrunnerPluginTests",
            dependencies: ["LinkrunnerPlugin"],
            path: "ios/Tests/LinkrunnerPluginTests")
    ]
)