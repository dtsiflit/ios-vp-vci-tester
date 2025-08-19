//
//  eudi-openid4vci-ios-app
//
import Swinject

public final class LogicUIAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {
    container.register(OfferScanInteractorType.self) { _ in
      OfferScanInteractor()
    }
    .inObjectScope(.container)
  }
}
