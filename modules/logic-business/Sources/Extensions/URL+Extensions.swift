//
//  eudi-openid4vci-ios-app
//
import Foundation

extension URL {
  func authorizationCode() throws -> String {
    guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
          let queryItems = urlComponents.queryItems,
          let codeItem = queryItems.first(where: { $0.name == "code" }),
          let code = codeItem.value else {
      throw CredentialIssuanceError.missingAuthorizationCode
    }
    return code
  }
}
