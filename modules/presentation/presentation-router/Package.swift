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
      path: "../domain/domain-business"
    ),
    .package(
      name: "api-client",
      path: "../domain/api-client"
    ),
    .package(
      name: "presentation-ui",
      path: "../presentation/presentation-ui"
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
      name: "document-presentation",
      path: "../features/document-presentation"
    )
  ],
  targets: [
    .target(
      name: "presentation-router",
      dependencies: [
        "api-client",
        "domain-business",
        "presentation-ui",
        "service-vci",
        "service-vp",
        "document-presentation"
      ]
    ),
    .testTarget(
      name: "presentation-routerTests",
      dependencies: ["presentation-router"]
    ),
  ]
)
