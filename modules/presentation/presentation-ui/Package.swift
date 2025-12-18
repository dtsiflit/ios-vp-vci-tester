// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "presentation-ui",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "presentation-ui",
      targets: ["presentation-ui"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../domain-business"
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
      name: "api-client",
      path: "../api-client"
    )
  ],
  targets: [
    .target(
      name: "presentation-ui",
      dependencies: [
        "domain-business",
        "api-client",
        "service-vci",
        "service-vp"
      ]
    ),
    .testTarget(
      name: "presentation-uiTests",
      dependencies: ["presentation-ui"]
    )
  ]
)
