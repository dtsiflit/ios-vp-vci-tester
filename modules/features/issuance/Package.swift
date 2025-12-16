// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "issuance",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "issuance",
      targets: ["issuance"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../core/domain-business"
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
      name: "api",
      path: "../core/api"
    ),
    .package(
      url: "https://github.com/twostraws/CodeScanner",
      from: "2.4.1"
    )
  ],
  targets: [
    .target(
      name: "issuance",
      dependencies: [
        "domain-business",
        "presentation-ui",
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
      name: "issuanceTests",
      dependencies: ["issuance"]
    )
  ]
)

