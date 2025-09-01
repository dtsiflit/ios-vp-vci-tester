//
//  eudi-openid4vci-ios-app
//
import Foundation

enum SymbolManager: String {
  case issuance = "checkmark.seal.text.page.fill"
  case close = "xmark"
  case success = "checkmark.seal.fill"
  case failure = "xmark.octagon.fill"

  static func value(for symbol: SymbolManager) -> String {
    return symbol.rawValue
  }
}
