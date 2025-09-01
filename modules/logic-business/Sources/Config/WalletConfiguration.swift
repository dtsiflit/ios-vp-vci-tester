//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI

public enum WalletConfiguration {

  public static let scheme = "eudi-openid4ci"

  public static let clientConfig: OpenId4VCIConfig = .init(
    client: .public(id: "wallet-dev"),
    authFlowRedirectionURI: URL(string: "eudi-openid4ci://authorize")!,
    authorizeIssuanceConfig: .favorScopes
  )
}
