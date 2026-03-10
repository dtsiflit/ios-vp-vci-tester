// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
  name: "assembly",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "assembly",
      targets: ["assembly"]
    )
  ],
  dependencies: [
    .package(
      name: "domain-business",
      path: "../domain/domain-business"
    ),
    .package(
      name: "api-client",
      path: "../domain/api-client"
    ),
    .package(
      name: "presentation-ui",
      path: "../presentation/presentation-ui"
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
      name: "document-presentation",
      path: "../features/document-presentation"
    ),
    .package(
      name: "presentation-router",
      path: "../presentation/presentation-router"
    )
  ],
  targets: [
    .target(
      name: "assembly",
      dependencies: [
        "api-client",
        "domain-business",
        "presentation-ui",
        "service-vci",
        "service-vp",
        "document-presentation",
        "presentation-router"
      ]
    )
  ],
  swiftLanguageModes: [.v6]
)
