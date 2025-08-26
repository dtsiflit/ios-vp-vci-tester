//
//  eudi-openid4vci-ios-app
//
import Swinject

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
      CredentialIssuanceController(wallet: r.resolve(DemoWallet.self)!)
    }
    .inObjectScope(.container)
  }
}
