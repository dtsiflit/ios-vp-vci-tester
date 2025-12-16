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
      name: "api",
      path: "../api"
    ),
    .package(
      url: "https://github.com/twostraws/CodeScanner",
      from: "2.4.1"
    )
  ],
  targets: [
    .target(
      name: "presentation-ui",
      dependencies: [
        "domain-business",
        "api",
        "service-vci",
        "service-vp",
        .product(
          name: "CodeScanner",
          package: "CodeScanner"
        )
      ]
    ),
    .testTarget(
      name: "presentation-uiTests",
      dependencies: ["presentation-ui"]
    )
  ]
)
