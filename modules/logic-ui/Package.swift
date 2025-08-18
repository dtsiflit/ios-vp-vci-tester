// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "logic-ui",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "logic-ui",
      targets: ["logic-ui"]
    )
  ],
  dependencies: [
    .package(
      name: "logic-business",
      path: "./logic-business"
    )
  ],
  targets: [
    .target(
      name: "logic-ui",
      dependencies: [
        "logic-business"
      ]
    ),
    .testTarget(
      name: "logic-uiTests",
      dependencies: ["logic-ui"]
    )
  ]
)
