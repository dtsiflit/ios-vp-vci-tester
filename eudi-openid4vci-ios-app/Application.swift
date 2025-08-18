//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import logic_assembly

@main
struct Application: App {

  init() {
    DIGraph.assembleDependenciesGraph()
  }

  var body: some Scene {
    WindowGroup {
      EmptyView()
    }
  }
}
