// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSSolid",
    platforms: [
        // This package depends on iOSSignIn-- which needs at least iOS 13.
        // And I'm using @StateObject so, need iOS 14.
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "iOSSolid",
            targets: ["iOSSolid"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SyncServerII/iOSSignIn.git", from: "0.5.0"),
        .package(url: "https://github.com/SyncServerII/ServerShared.git", from: "0.12.10"),
        .package(url: "https://github.com/SyncServerII/iOSShared.git", from: "0.15.0"),
        .package(url: "https://github.com/crspybits/SolidAuthSwift.git", from: "0.0.10"),
        .package(url: "https://github.com/piknotech/SFSafeSymbols.git", from: "2.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "iOSSolid",
            dependencies: [
                "iOSSignIn", "ServerShared", "iOSShared",
                "SFSafeSymbols",
                .product(name: "SolidAuthSwiftUI", package: "SolidAuthSwift"),
            ],
            resources: [
                // Do *not* name this folder `Resources`. See https://stackoverflow.com/questions/52421999
                .copy("Images")
            ]),
        .testTarget(
            name: "iOSSolidTests",
            dependencies: ["iOSSolid"]),
    ]
)
