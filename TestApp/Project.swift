import ProjectDescription

let project = Project(
    name: "TestApp",
    targets: [
        .target(
            name: "TestApp",
            destinations: .iOS,
            product: .app,
            bundleId: "cloud.trustpin.TestApp",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            "trustpin.cloud": [
                                "NSExceptionAllowsInsecureHTTPLoads": false,
                                "NSExceptionMinimumTLSVersion": "TLSv1.2",
                                "NSExceptionRequiresForwardSecrecy": true,
                                "NSIncludesSubdomains": true
                            ]
                        ]
                    ]                    
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "Sources/Assets.xcassets",
                "Sources/LaunchScreen.storyboard",
                "Sources/trustpin.png"
            ],
            entitlements: "Sources/TestApp.entitlements",
            dependencies: [
                .external(name: "TrustPinKit")
            ]
        )
    ]
)
