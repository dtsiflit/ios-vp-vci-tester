// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "service-vp",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "service-vp",
      targets: ["service-vp"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/Swinject/Swinject.git",
      from: "2.9.1"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-siop-openid4vp-swift",
      from: "0.16.0"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/SwiftCopyableMacro.git",
      from: "0.0.4"
    )
  ],
  targets: [
    .target(
      name: "service-vp",
      dependencies: [
        "Swinject",
        .product(
          name: "OpenID4VP",
          package: "eudi-lib-ios-openid4vci-swift"
        ),
        .product(
          name: "Copyable",
          package: "SwiftCopyableMacro"
        )
      ]
    ),
    .testTarget(
      name: "service-vpTests",
      dependencies: ["service-vp"]
    )
  ]
)
