// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "smith-foundation",
    platforms: [
        .macOS(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "SmithProgress", targets: ["SmithProgress"]),
        .library(name: "SmithErrorHandling", targets: ["SmithErrorHandling"]),
        .library(name: "SmithOutputFormatter", targets: ["SmithOutputFormatter"]),
    ],
    targets: [
        .target(name: "SmithProgress"),
        .target(name: "SmithErrorHandling"),
        .target(name: "SmithOutputFormatter"),
    ]
)
