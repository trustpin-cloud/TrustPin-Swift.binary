// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TrustPinKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
        .macCatalyst(.v13),
        .watchOS(.v7),
        .tvOS(.v13)
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
            url: "https://github.com/trustpin-cloud/TrustPin-Swift.binary/releases/download/0.17.0/TrustPinKit-0.17.0.xcframework.zip",
            checksum: "3a0f8bf4e6a6b396d03adb5298219151862bc25a37fd8cb013b0b9a63bc32e8e"
        )
    ]
)
