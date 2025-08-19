//
//  eudi-openid4vci-ios-app
//
import Foundation

public protocol OpenID4VCIConfigType: Sendable {
  var translations: [String: [LocalizableKey: String]] { get }
  var printLogs: Bool { get }
}

public struct OpenID4VCIConfig: OpenID4VCIConfigType {
  public var translations: [String: [LocalizableKey: String]] = [:]
  public var printLogs: Bool = false
}

extension OpenID4VCIConfigType {
  public var translations: [String: [LocalizableKey: String]] {
    [:]
  }
}
