// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "logic-assembly",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "logic-assembly",
      targets: ["logic-assembly"]
    )
  ],
  dependencies: [
    .package(
      name: "logic-business",
      path: "./logic-business"
    ),
    .package(
      name: "logic-ui",
      path: "./logic-ui"
    )
  ],
  targets: [
    .target(
      name: "logic-assembly",
      dependencies: [
        "logic-business",
        "logic-ui"
      ]
    )
  ]
)
