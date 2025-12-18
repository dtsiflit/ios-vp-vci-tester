// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "api-client",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "api-client",
      targets: ["api-client"]
    ),
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../domain-business"
    ),
  ],
  targets: [
    .target(
      name: "api-client",
      dependencies: [
        "domain-business"
      ]
    ),
    .testTarget(
      name: "api-clientTests",
      dependencies: ["api-client"]
    ),
  ]
)
