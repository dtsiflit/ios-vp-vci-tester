//
//  eudi-openid4vci-ios-app
//
import Foundation
import Swinject

public final class LogicUIAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {

    container.register(OfferScanInteractorType.self) { _ in
      OfferScanInteractor()
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
