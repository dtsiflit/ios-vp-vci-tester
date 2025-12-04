// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "api",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "api",
      targets: ["api"]
    ),
  ],
  dependencies: [
    .package(
      name: "domain-business-logic",
      path: "../../domain-business-logic"
    ),
  ],
  targets: [
    .target(
      name: "api",
      dependencies: [
        "domain-business-logic"
      ]
    ),
    .testTarget(
      name: "apiTests",
      dependencies: ["api"]
    ),
  ]
)
