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
            url: "https://github.com/trustpin-cloud/TrustPin-Swift.binary/releases/download/2.0.0/TrustPinKit-2.0.0.xcframework.zip",
            checksum: "e5d4f4102b96b2238609b97ce1b8ecbbce9fa9a6c58ac4e488efb00c32b7b2ab"
        )
    ]
)
