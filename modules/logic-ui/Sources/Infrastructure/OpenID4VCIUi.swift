//
//  eudi-openid4vci-ios-app
//
import Foundation

public final actor OpenID4VCIUi { }

public extension OpenID4VCIUi {
  enum State: Equatable, Sendable {

    case none
    case offerScanView
    case issuanceProgressView
    case issuanceResultView

    var id: String {
      return switch self {
      case .none:
        "none"
      case .offerScanView:
        "offerScanView"
      case .issuanceProgressView:
        "issuanceProgressView"
      case .issuanceResultView:
        "issuanceResultView"
      }
    }

    public static func == (lhs: State, rhs: State) -> Bool {
      return lhs.id == rhs.id
    }
  }
}
