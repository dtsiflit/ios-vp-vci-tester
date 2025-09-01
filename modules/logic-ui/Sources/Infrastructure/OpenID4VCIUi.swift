//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI

public final actor OpenID4VCIUi { }

public extension OpenID4VCIUi {
  enum State: Equatable, Sendable {

    case none
    case credentialOffer
    case credentialOfferResultView(credential: CredentialOfferResultType)

    var id: String {
      return switch self {
      case .none:
        "none"
      case .credentialOffer:
        "credentialOffer"
      case .credentialOfferResultView:
        "credentialOfferResultView"
      }
    }

    public static func == (lhs: State, rhs: State) -> Bool {
      return lhs.id == rhs.id
    }
  }
}
