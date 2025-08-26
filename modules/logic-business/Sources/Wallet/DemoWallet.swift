//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI

public struct ActingUser: Sendable {
  public let username: String
  public let password: String

  public init(username: String, password: String) {
    self.username = username
    self.password = password
  }
}

final class DemoWallet: Sendable {

  let actingUser: ActingUser
  let bindingKeys: [BindingKey]
  let session: Networking

  init(
    actingUser: ActingUser,
    bindingKeys: [BindingKey],
    session: Networking
  ) {
    self.actingUser = actingUser
    self.bindingKeys = bindingKeys
    self.session = session
  }

  static let walletSession: Networking = {
    /*let delegate = SelfSignedSessionDelegate()
     let configuration = URLSessionConfiguration.default
     return URLSession(
     configuration: configuration,
     delegate: delegate,
     delegateQueue: nil
     )*/
    URLSession.shared
  }()
}

extension DemoWallet {
  func issueByCredentialOfferUrl(
    offerUri: String,
    scope: String,
    config: OpenId4VCIConfig
  ) async throws -> Credential {
    let result = await CredentialOfferRequestResolver(
      fetcher: Fetcher(session: self.session),
      credentialIssuerMetadataResolver: CredentialIssuerMetadataResolver(
        fetcher: Fetcher(session: self.session)
      ),
      authorizationServerMetadataResolver: AuthorizationServerMetadataResolver(
        oidcFetcher: Fetcher(session: self.session),
        oauthFetcher: Fetcher(session: self.session)
      )
    ).resolve(
      source: try .init(
        urlString: offerUri
      ),
      policy: config.issuerMetadataPolicy
    )

    switch result {
    case .success:
//      return try await issueOfferedCredentialWithProof(
//        offer: offer,
//        scope: scope,
//        config: config
//      )
      return .string("dummy-credential-for-\(scope)")
    case .failure(let error):
      throw ValidationError.error(reason: "Unable to resolve credential offer: \(error.localizedDescription)")
    }
  }
}
