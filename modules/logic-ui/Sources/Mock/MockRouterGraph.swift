//
//  eudi-openid4vci-ios-app
//
import SwiftUI

public final class MockRouterGraph: RouterGraphType, @unchecked Sendable {
  @Published public var path: NavigationPath = .init()

  public init() {}

  public func navigateTo(_ appRoute: Route) { }
  public func pop() { }
  public func navigateToRoot() { }
  public func view(for route: Route) -> AnyView { AnyView(EmptyView()) }
  public func nextView(for state: OpenID4VCIUi.State) throws -> UIViewController {
    UIViewController()
  }
  public func clear() { path = .init() }
}
