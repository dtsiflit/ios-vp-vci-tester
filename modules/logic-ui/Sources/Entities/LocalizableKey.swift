//
//  eudi-openid4vci-ios-app
//

public enum LocalizableKey: Sendable, Equatable, Hashable {

  case custom(String)
  case actions
  case credentialIssuanceCardLabel
  case credentialIssuanceCardDescription
  case credentialIssuanceCardButtonLabel
  case successIssuanceResultTitle
  case successIssuanceResultDescription
  case failureIssuanceResultTitle
  case failureIssuanceResultDescription

  func defaultTranslation(args: [String]) -> String {
    let value = switch self {
    case .custom(let literal): literal
    case .actions:
      "Actions"
    case .credentialIssuanceCardLabel:
      "Credential Offer"
    case .credentialIssuanceCardDescription:
      "Tap to open the scanner and scan a QR code."
    case .credentialIssuanceCardButtonLabel:
      "Open Scanner"
    case .successIssuanceResultTitle:
      "Success"
    case .successIssuanceResultDescription:
      "The credential was issued successfully."
    case .failureIssuanceResultTitle:
      "Error"
    case .failureIssuanceResultDescription:
      "Oops! We couldn't issue your credential this time."
    }
    return value.format(arguments: args)
  }
}
