//
//  eudi-openid4vci-ios-app
//
import Foundation

public enum CredentialIssuanceError: LocalizedError {
  case missingAuthorizationCode
  case missingAuthorizationServerMetadata
  case missingCredentialConfigurationIdentifier
  case failedAuthorizationRequest(reason: String)
  case failedCredentialRequest(reason: String)
  case deferredIssuance
  case unknown(reason: String)

  public var errorDescription: String? {
    switch self {
    case .missingAuthorizationCode:
      return "Authorization code not found in callback URL."
    case .missingAuthorizationServerMetadata:
      return "Missing authorization server metadata."
    case .missingCredentialConfigurationIdentifier:
      return "Credential configuration identifier not found."
    case .failedAuthorizationRequest(let reason):
      return "Authorization request failed: \(reason)"
    case .failedCredentialRequest(let reason):
      return "Credential request failed: \(reason)"
    case .deferredIssuance:
      return "Credential issuance was deferred."
    case .unknown(let reason):
      return "Unknown error: \(reason)"
    }
  }
}
