// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "domain-business",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "domain-business",
      targets: ["domain-business"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/Swinject/Swinject.git",
      from: "2.9.1"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vci-swift.git",
      from: "0.17.0"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/SwiftCopyableMacro.git",
      from: "0.0.4"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-openid4vp-swift",
      from: "0.19.0"
    ),
    .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "3.0.0")
  ],
  targets: [
    .target(
      name: "domain-business",
      dependencies: [
        "Swinject",
        .product(
          name: "OpenID4VCI",
          package: "eudi-lib-ios-openid4vci-swift"
        ),
        .product(
          name: "Copyable",
          package: "SwiftCopyableMacro"
        ),
        .product(
          name: "OpenID4VP",
          package: "eudi-lib-ios-openid4vp-swift"
        ),
        .product(name: "JOSESwift", package: "JOSESwift")
      ]
    ),
    .testTarget(
      name: "domain-businessTests",
      dependencies: ["domain-business"]
    )
  ]
)
