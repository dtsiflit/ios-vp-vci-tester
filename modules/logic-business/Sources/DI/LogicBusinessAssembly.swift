//
//  eudi-openid4vci-ios-app
//
import Swinject
import Foundation
import OpenID4VCI
import JOSESwift

public final class LogicBusinessAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {
    container.register(CredentialIssuanceControllerType.self) { _ in
      CredentialIssuanceController(
        bindingKeys: [BindingKeys.bindingKey],
        clientConfig: WalletConfiguration.clientConfig,
        credentialOfferRequestResolver: .init()
      )
    }
    .inObjectScope(.container)
  }

}
