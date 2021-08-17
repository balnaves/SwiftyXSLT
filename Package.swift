// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyXSLT",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyXSLT",
            targets: ["SwiftyXSLT"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "libxslt",
            dependencies: [],
            cxxSettings: [
                .define("MODULEMAP_FILE", to: "module.modulemap")
            ]
        ),
        .target(
            name: "SwiftyXSLT",
            dependencies: ["libxslt"]
        ),
        .testTarget(
            name: "SwiftyXSLTTests",
            dependencies: ["SwiftyXSLT"]
        ),
    ]
)
