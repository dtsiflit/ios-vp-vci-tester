//
//  eudi-openid4vci-ios-app
//

public enum LocalizableKey: Sendable, Equatable, Hashable {

  case custom(String)
  case next

  func defaultTranslation(args: [String]) -> String {
    let value = switch self {
    case .custom(let literal): literal
    case .next: "Next"
    }
    return value.format(arguments: args)
  }
}
