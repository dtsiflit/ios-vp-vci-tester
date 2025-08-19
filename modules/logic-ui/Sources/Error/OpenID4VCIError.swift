//
//  eudi-openid4vci-ios-app
//
import Foundation

public enum OpenID4VCIError: LocalizedError {

  case invalidState(String)

  public var errorDescription: String? {
    return switch self {
    case .invalidState(let stateName):
      "State is Invalid - \(stateName)"
    }
  }
}
