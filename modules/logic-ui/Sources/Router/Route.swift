//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI

public enum Route: Hashable, Identifiable, Equatable {
  case credentialOffer
  case credentialOfferResultView(config: CredentialOfferResultType)

  public var id: String {
    switch self {
    case .credentialOffer: return "credentialOffer"
    case .credentialOfferResultView: return "credentialOfferResultView"
    }
  }

  public static func == (lhs: Route, rhs: Route) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
