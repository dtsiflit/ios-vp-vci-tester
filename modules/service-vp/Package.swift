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
    )
  ],
  targets: [
    .target(
      name: "service-vp",
      dependencies: [
        "Swinject"
      ]
    ),
    .testTarget(
      name: "service-vpTests",
      dependencies: ["service-vp"]
    )
  ]
)
