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

    let privateKey = try! KeyController.generateECDHPrivateKey()
    let publicKey = try! KeyController.generateECDHPublicKey(from: privateKey)
    
    let alg = JWSAlgorithm(.ES256)
    let publicKeyJWK = try! ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ])
    
    let bindingKey: BindingKey = .jwk(
      algorithm: alg,
      jwk: publicKeyJWK,
      privateKey: .secKey(privateKey)
    )
    
    container.register(CredentialIssuanceControllerType.self) { _ in
      CredentialIssuanceController(
        bindingKeys: [bindingKey],
        clientConfig: .init(
          client: .public(id: "wallet-dev"),
          authFlowRedirectionURI: URL(string: "eudi-openid4ci://authorize")!,
          authorizeIssuanceConfig: .favorScopes
        )
      )
    }
    .inObjectScope(.container)
  }
}
