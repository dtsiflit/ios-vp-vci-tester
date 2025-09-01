//
//  eudi-openid4vci-ios-app
//

public enum LocalizableKey: Sendable, Equatable, Hashable {

  case custom(String)
  case actions
  case close
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
      "Issue Credential"
    case .credentialIssuanceCardDescription:
      "Tap to open the QR code scanner to issue your credential."
    case .close:
      "Close"
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
