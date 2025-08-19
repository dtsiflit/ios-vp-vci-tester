//
//  eudi-openid4vci-ios-app
//
import SwiftUI

extension String {
  var toLocalizedStringKey: LocalizedStringKey {
    LocalizedStringKey(self)
  }
  func format(arguments: [CVarArg]? = nil) -> String {
    guard let arguments, !arguments.isEmpty else {
      return self
    }
    return String(format: self, locale: nil, arguments: arguments)
  }
}
