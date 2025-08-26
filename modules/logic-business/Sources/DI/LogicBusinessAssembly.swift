//
//  eudi-openid4vci-ios-app
//
import Swinject
import Foundation

public final class LogicBusinessAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {
    container.register(DemoWallet.self) { _ in
      DemoWallet(
        actingUser: ActingUser(
          username: "demo",
          password: "demo"
        ),
        bindingKeys: [],
        session: DemoWallet.walletSession
      )
    }
    .inObjectScope(.container)

    container.register(CredentialIssuanceControllerType.self) { r in
      CredentialIssuanceController(
        bindingKeys: [],
        clientConfig: .init(
          client: .public(id: "wallet-dev"),
          authFlowRedirectionURI: URL(string: "urn:ietf:wg:oauth:2.0:oob")!,
          authorizeIssuanceConfig: .favorScopes
        )
      )
    }
    .inObjectScope(.container)
  }
}
