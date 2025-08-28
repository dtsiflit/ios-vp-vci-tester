//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import OpenID4VCI

public struct CredentialOfferResultConfiguration: Sendable {
  let title: String
  let symbolName: String
  let symbolColor: Color
  let description: String
}

public enum CredentialOfferResultType: Sendable {
  case success(Credential)
  case failure(Error)

  var configuration: CredentialOfferResultConfiguration {
    switch self {
    case .success:
      return CredentialOfferResultConfiguration(
        title: "Success",
        symbolName: SymbolManager.value(for: .success),
        symbolColor: .green,
        description: "The credential was issued successfully."
      )
    case .failure:
      return CredentialOfferResultConfiguration(
        title: "Error",
        symbolName: SymbolManager.value(for: .failure),
        symbolColor: .red,
        description: "Oops! We couldn't issue your credential this time."
      )
    }
  }
}
