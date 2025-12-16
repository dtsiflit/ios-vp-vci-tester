// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "presentation-common",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "presentation-common",
      targets: ["presentation-common"]
    ),
  ],
  dependencies: [
    .package(
      name: "presentation-ui",
      path: "../presentation-ui"
    ),
    .package(
      url: "https://github.com/twostraws/CodeScanner",
      from: "2.4.1"
    )
  ],
  targets: [
    .target(
      name: "presentation-common",
      dependencies: [
        "presentation-ui",
        .product(
          name: "CodeScanner",
          package: "CodeScanner"
        )
      ]
    ),
    .testTarget(
      name: "presentation-commonTests",
      dependencies: ["presentation-common"]
    ),
  ]
)
