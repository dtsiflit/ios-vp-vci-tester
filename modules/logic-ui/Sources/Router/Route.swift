//
//  eudi-openid4vci-ios-app
//
import Foundation

public enum Route: Hashable, Identifiable, Equatable {

  case credentialOffer
  case issuanceProgressView
  case issuanceResultView

  public var id: String {
    switch self {
    case .credentialOffer:
      return "credentialOffer"
    case .issuanceProgressView:
      return "issuanceProgressView"
    case .issuanceResultView:
      return "issuanceResultView"
    }
  }

  public static func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .credentialOffer:
      hasher.combine("credentialOffer")
    case .issuanceProgressView:
      hasher.combine("issuanceProgressView")
    case .issuanceResultView:
      hasher.combine("issuanceResultView")
    }
  }
}
