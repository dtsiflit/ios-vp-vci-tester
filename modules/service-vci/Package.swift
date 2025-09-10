// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "service-vci",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "service-vci",
      targets: ["service-vci"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business-logic",
      path: "./domain-business-logic"
    ),
    .package(
      url: "https://github.com/Swinject/Swinject.git",
      from: "2.9.1"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vci-swift.git",
      from: "0.15.4"
    )
  ],
  targets: [
    .target(
      name: "service-vci",
      dependencies: [
        "Swinject",
        "domain-business-logic",
        .product(
          name: "OpenID4VCI",
          package: "eudi-lib-ios-openid4vci-swift"
        )
      ]
    ),
    .testTarget(
      name: "service-vciTests",
      dependencies: ["service-vci"]
    )
  ]
)
