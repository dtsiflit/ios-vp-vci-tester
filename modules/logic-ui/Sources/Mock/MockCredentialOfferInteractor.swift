//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI
import SwiftyJSON

public final class MockCredentialOfferInteractor: CredentialOfferInteractorType {

  public init() {}

  public func issueCredential(offerUri: String, scope: String) async -> Result<Credential, Error> {
    try? await Task.sleep(nanoseconds: 100_000_000)

    let jsonCredential: JSON = [
      "id": "mock-credential-\(UUID().uuidString)",
      "type": ["MockCredential"],
      "issuanceDate": ISO8601DateFormatter().string(from: Date()),
      "credentialSubject": [
        "name": "Demo User",
        "scope": scope
      ]
    ]

    let mockCredential = Credential.json(jsonCredential)
    return .success(mockCredential)
  }

  func resolveCredentialIssuerMetadata(
    _ resolver: CredentialIssuerMetadataResolver,
    _ id: CredentialIssuerId,
    _ policy: IssuerMetadataPolicy
  ) async throws -> Result<CredentialIssuerMetadata, any Error> {
    throw ValidationError.todo(reason: "Implement soon")
  }

  func resolveAuthorizationServerMetadata(
    _ resolver: AuthorizationServerMetadataResolver,
    _ credentialIssuerMetadata: CredentialIssuerMetadata
  ) async throws -> Result<IdentityAndAccessManagementMetadata, any Error> {
    throw ValidationError.todo(reason: "Implement soon")
  }

  func getCredentialOffer(
    _ identifier: String,
    _ credentialIssuerIdentifier: CredentialIssuerId,
    _ credentialIssuerMetadata: CredentialIssuerMetadata,
    _ authorizationServerMetadata: IdentityAndAccessManagementMetadata
  ) async throws -> CredentialOffer {
    throw ValidationError.todo(reason: "Implement soon")
  }

  func getIssuer(
    _ credentialOffer: CredentialOffer,
    _ dPoPConstructor: (any DPoPConstructorType)?,
    _ config: OpenId4VCIConfig
  ) async throws -> Issuer {
    throw ValidationError.todo(reason: "Implement soon")
  }

  func authorizeRequestWithAuthCodeUseCase(
    issuer: any IssuerType,
    offer: CredentialOffer
  ) async throws -> AuthorizedRequest {
    throw ValidationError.todo(reason: "Implement soon")
  }

  func issueCredential(
    _ issuer: Issuer,
    _ authorized: AuthorizedRequest,
    _ credentialConfigurationIdentifier: CredentialConfigurationIdentifier?
  ) async throws -> Credential {
    throw ValidationError.todo(reason: "Implement soon")
  }
}
