// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TrustPinKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
        .macCatalyst(.v13),
        .watchOS(.v7),
        .tvOS(.v13),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "TrustPinKit",
            targets: ["TrustPinKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "TrustPinKit",
            url: "https://github.com/trustpin-cloud/TrustPin-Swift.binary/releases/download/0.21.0/TrustPinKit-0.21.0.xcframework.zip",
            checksum: "624331d8832bd21fca1ded495a006ebb5a59db211a541c0ac51527ef4c8093f3"
        )
    ]
)
