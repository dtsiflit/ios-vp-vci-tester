/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import SwiftUI
import service_vci
import domain_business

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
      CredentialOfferResultView(
        with: .init(
          router: self,
          config: config,
          interactor: DIGraph.resolver.force(
            CredentialPresentationInteractorType.self
          )
        )
      )
      .eraseToAnyView()
    case .deferredPendingView(let credentialOutcome):
      DeferredPendingView(
        with: .init(
          router: self,
          interactor: DIGraph.resolver.force(
            CredentialOfferInteractorType.self
          ),
          credentialOutcome: credentialOutcome
        )
      )
      .eraseToAnyView()
    case .credentialPresentationResult(let config):
      CredentialPresentationResultView(
        with: .init(
          router: self,
          config: config
        )
      )
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
          CredentialOfferResultView(
            with: .init(
              router: self,
              config: config,
              interactor: DIGraph.resolver.force(
                CredentialPresentationInteractorType.self
              )
            )
          )
          .eraseToAnyView()
        case .deferredPendingView(let credentialOutcome):
          DeferredPendingView(
            with: .init(
              router: self,
              interactor: DIGraph.resolver.force(
                CredentialOfferInteractorType.self
              ),
              credentialOutcome: credentialOutcome
            )
          )
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
