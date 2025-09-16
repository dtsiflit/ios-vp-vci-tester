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
      name: "domain-business-logic",
      path: "./domain-business-logic"
    ),
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
    ),
    .package(
      url: "https://github.com/krzyzanowskim/CryptoSwift.git",
      from: "1.8.4"
    )
  ],
  targets: [
    .target(
      name: "service-vp",
      dependencies: [
        "domain-business-logic",
        "Swinject",
        .product(
          name: "SiopOpenID4VP",
          package: "eudi-lib-ios-siop-openid4vp-swift"
        ),
        .product(
          name: "Copyable",
          package: "SwiftCopyableMacro"
        ),
        .product(
          name: "CryptoSwift",
          package: "CryptoSwift"
        )
      ]
    ),
    .testTarget(
      name: "service-vpTests",
      dependencies: ["service-vp"]
    )
  ]
)
