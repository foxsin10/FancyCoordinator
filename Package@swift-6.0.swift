// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "FancyCoordinator",
  platforms: [.iOS(.v15), .watchOS(.v8), .macOS(.v12)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "FancyCoordinator",
      targets: ["FancyCoordinator"]
    ),
    .library(
      name: "FancyCoordinatorWithCasePath",
      targets: ["FancyCoordinatorWithCasePath"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.9.2")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "FancyCoordinator",
      dependencies: []
    ),
    .testTarget(
      name: "FancyCoordinatorTests",
      dependencies: ["FancyCoordinator", "FancyCoordinatorWithCasePath"]
    ),

    .target(
      name: "FancyCoordinatorWithCasePath",
      dependencies: [
        "FancyCoordinator",
        .product(name: "CasePaths", package: "swift-case-paths")
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)
