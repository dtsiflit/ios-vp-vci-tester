//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import assembly

@main
struct Application: App {

  @StateObject private var router = RouterGraph()

  init() {
    DIGraph.assembleDependenciesGraph()
  }

  var body: some Scene {
    WindowGroup {
      ContainerView(router: router) {
        $0.view(for: .credentialOffer)
      }
    }
  }
}
