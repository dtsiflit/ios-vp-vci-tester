// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "presentation-router",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "presentation-router",
      targets: ["presentation-router"]
    ),
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../core/domain-business"
    ),
    .package(
      name: "api",
      path: "../core/api"
    ),
    .package(
      name: "presentation-ui",
      path: "../core/presentation-ui"
    ),
    .package(
      name: "service-vci",
      path: "../services/service-vci"
    ),
    .package(
      name: "service-vp",
      path: "../services/service-vp"
    ),
    .package(
      name: "issuance",
      path: "../features/issuance"
    )
  ],
  targets: [
    .target(
      name: "presentation-router",
      dependencies: [
        "api",
        "domain-business",
        "presentation-ui",
        "service-vci",
        "service-vp",
        "issuance"
      ]
    ),
    .testTarget(
      name: "presentation-routerTests",
      dependencies: ["presentation-router"]
    ),
  ]
)
