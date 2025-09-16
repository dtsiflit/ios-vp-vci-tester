// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "assembly",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "assembly",
      targets: ["assembly"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business-logic",
      path: "./domain-business-logic"
    ),
    .package(
      name: "presentation-ui",
      path: "./presentation-ui"
    ),
    .package(
      name: "service-vci",
      path: "./service-vci"
    ),
    .package(
      name: "service-vp",
      path: "./service-vp"
    )
  ],
  targets: [
    .target(
      name: "assembly",
      dependencies: [
        "domain-business-logic",
        "presentation-ui",
        "service-vci",
        "service-vp"
      ]
    )
  ]
)
