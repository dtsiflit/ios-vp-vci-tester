//
//  eudi-openid4vci-ios-app
//
import SwiftUI

public struct ContainerView<Router: RouterGraph, Content: View>: View {

  @ObservedObject var router: Router
  public let content: Content

  public init(router: Router, @ViewBuilder content: @escaping (Router) -> Content) {
    self.router = router
    self.content = content(router)
  }

  public var body: some View {
    NavigationStack(path: $router.path) {
      content
        .navigationDestination(for: Route.self) { route in
          router.view(for: route)
        }
    }
  }
}
