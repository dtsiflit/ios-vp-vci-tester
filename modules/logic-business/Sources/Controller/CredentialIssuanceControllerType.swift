//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI

public protocol CredentialIssuanceControllerType: Sendable {
  func issueCredential(from offerUri: String, scope: String) async -> Result<Credential, Error>
}

final class CredentialIssuanceController: CredentialIssuanceControllerType {

  private let wallet: DemoWallet

  private let clientConfig: OpenId4VCIConfig = .init(
    client: .public(id: "wallet-dev"),
    authFlowRedirectionURI: URL(string: "urn:ietf:wg:oauth:2.0:oob")!,
    authorizeIssuanceConfig: .favorScopes
  )

  init(wallet: DemoWallet) {
    self.wallet = wallet
  }

  func issueCredential(from offerUri: String, scope: String) async -> Result<Credential, Error> {
    do {
      let credential = try await wallet.issueByCredentialOfferUrl(
        offerUri: offerUri,
        scope: scope,
        config: clientConfig
      )
      return .success(credential)
    } catch {
      return .failure(error)
    }
  }
}
