// swift-tools-version: 6.1
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
            url: "https://github.com/trustpin-cloud/TrustPin-Swift.binary/releases/download/1.1.0/TrustPinKit-1.1.0.xcframework.zip",
            checksum: "6465ea157beedc50a96e78a8bca69f18dc7b14712aea6c189854f546acd8b28c"
        )
    ]
)
