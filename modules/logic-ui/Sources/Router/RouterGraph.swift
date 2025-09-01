//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import logic_business

public protocol RouterGraphType: ObservableObject, Sendable {
  var path: NavigationPath { get set }

  @MainActor func navigateTo(_ appRoute: Route)
  @MainActor func pop()
  @MainActor func navigateToRoot()
  @MainActor func view(for route: Route) -> AnyView
  @MainActor func nextView(for state: OpenID4VCIUi.State) throws -> UIViewController
  @MainActor func clear()
}

public final class RouterGraph: RouterGraphType, @unchecked Sendable {
  @Published public var path: NavigationPath = NavigationPath()

  public init() {}

  public func view(for route: Route) -> AnyView {
    switch route {
    case .credentialOffer:
      CredentialOfferView(
        with: .init(
          router: self,
          interactor: DIGraph.resolver.force(
            CredentialOfferInteractorType.self
          )
        )
      )
      .eraseToAnyView()
    case .credentialOfferResultView(let config):
      CredentialOfferResultView(for: config)
        .eraseToAnyView()
    }
  }

  public func nextView(for state: OpenID4VCIUi.State) throws -> UIViewController {
    guard state != .none else {
      throw CredentialIssuanceError.unknown(reason: state.id)
    }

    return ContainerViewController(
      rootView: ContainerView(
        router: self
      ) { _ in
        switch state {
        case .none:
          EmptyView()
        case .credentialOffer:
          CredentialOfferView(
            with: .init(
              router: self,
              interactor: DIGraph.resolver.force(
                CredentialOfferInteractorType.self
              )
            )
          )
          .eraseToAnyView()
        case .credentialOfferResultView(let config):
          CredentialOfferResultView(for: config)
            .eraseToAnyView()
        }
      }
    )
  }

  public func navigateTo(_ appRoute: Route) {
    path.append(appRoute)
  }

  public func pop() {
    path.removeLast()
  }

  public func navigateToRoot() {
    path.removeLast(path.count)
  }

  public func clear() {
    if !path.isEmpty {
      path = NavigationPath()
    }
  }
}
