// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "document-presentation",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "document-presentation",
      targets: ["document-presentation"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../domain/domain-business"
    ),
    .package(
      name: "presentation-ui",
      path: "../presentation/presentation-ui"
    ),
    .package(
      name: "presentation-common",
      path: "../presentation/presentation-common"
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
      name: "api-client",
      path: "../domain/api-client"
    ),
    .package(
      url: "https://github.com/twostraws/CodeScanner",
      from: "2.4.1"
    )
  ],
  targets: [
    .target(
      name: "document-presentation",
      dependencies: [
        "domain-business",
        "presentation-ui",
        "presentation-common",
        "api-client",
        "service-vci",
        "service-vp",
        .product(
          name: "CodeScanner",
          package: "CodeScanner"
        )
      ]
    ),
    .testTarget(
      name: "document-presentationTests",
      dependencies: ["document-presentation"]
    )
  ]
)

