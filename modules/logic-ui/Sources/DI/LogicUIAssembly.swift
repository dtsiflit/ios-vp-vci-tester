//
//  eudi-openid4vci-ios-app
//
import Swinject
import Foundation
import logic_business

public final class LogicUIAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {

    container.register(CredentialOfferInteractorType.self) { r in
      CredentialOfferInteractor(
        controller: r.force(CredentialIssuanceControllerType.self)
      )
    }
    .inObjectScope(.container)

    container.register(LocalizationControllerType.self) { _ in
      return LocalizationController(
        config: OpenID4VCIConfig(),
        locale: Locale.current
      )
    }
    .inObjectScope(.container)
  }
}
