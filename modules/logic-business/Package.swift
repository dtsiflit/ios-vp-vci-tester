// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "logic-business",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "logic-business",
      targets: ["logic-business"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/Swinject/Swinject.git",
      from: "2.9.1"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vci-swift.git",
      from: "0.15.4"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/SwiftCopyableMacro.git",
      from: "0.0.4"
    )
  ],
  targets: [
    .target(
      name: "logic-business",
      dependencies: [
        "Swinject",
        .product(
          name: "OpenID4VCI",
          package: "eudi-lib-ios-openid4vci-swift"
        ),
        .product(
          name: "Copyable",
          package: "SwiftCopyableMacro"
        )
      ]
    ),
    .testTarget(
      name: "logic-businessTests",
      dependencies: ["logic-business"]
    )
  ]
)
