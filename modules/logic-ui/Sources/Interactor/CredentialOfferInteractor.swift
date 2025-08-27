//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI
import AuthenticationServices
import logic_business

protocol CredentialOfferInteractorType: Sendable {

  func issueCredential(offerUri: String, scope: String) async -> Result<Credential, Error>

  func resolveCredentialIssuerMetadata(
    _ resolver: CredentialIssuerMetadataResolver,
    _ id: CredentialIssuerId,
    _ policy: IssuerMetadataPolicy
  ) async throws -> Result<CredentialIssuerMetadata, Error>

  func resolveAuthorizationServerMetadata(
    _ resolver: AuthorizationServerMetadataResolver,
    _ credentialIssuerMetadata: CredentialIssuerMetadata
  ) async throws -> Result<IdentityAndAccessManagementMetadata, Error>

  func getCredentialOffer(
    _ identifier: String,
    _ credentialIssuerIdentifier: CredentialIssuerId,
    _ credentialIssuerMetadata: CredentialIssuerMetadata,
    _ authorizationServerMetadata: IdentityAndAccessManagementMetadata
  ) async throws -> CredentialOffer

  func getIssuer(
    _ credentialOffer: CredentialOffer,
    _ dPoPConstructor: DPoPConstructorType?,
    _ config: OpenId4VCIConfig
  ) async throws -> Issuer

  func authorizeRequestWithAuthCodeUseCase(
    issuer: IssuerType,
    offer: CredentialOffer
  ) async throws -> AuthorizedRequest

  func issueCredential(
    _ issuer: Issuer,
    _ authorized: AuthorizedRequest,
    _ credentialConfigurationIdentifier: CredentialConfigurationIdentifier?
  ) async throws -> Credential
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {
  private let controller: CredentialIssuanceControllerType

  init(controller: CredentialIssuanceControllerType) {
    self.controller = controller
  }

  func issueCredential(
    offerUri: String,
    scope: String
  ) async -> Result<Credential, Error> {
    return .failure(ValidationError.todo(reason: "Not implemented"))
  }

  func resolveCredentialIssuerMetadata(
    _ resolver: CredentialIssuerMetadataResolver,
    _ id: CredentialIssuerId,
    _ policy: IssuerMetadataPolicy
  ) async throws -> Result<CredentialIssuerMetadata, Error> {
    return try await controller.resolveCredentialIssuerMetadata(resolver, id, policy)
  }

  func resolveAuthorizationServerMetadata(
    _ resolver: AuthorizationServerMetadataResolver,
    _ credentialIssuerMetadata: CredentialIssuerMetadata
  ) async throws -> Result<IdentityAndAccessManagementMetadata, Error> {
    return try await controller.resolveAuthorizationServerMetadata(resolver, credentialIssuerMetadata)
  }

  func getCredentialOffer(
    _ identifier: String,
    _ credentialIssuerIdentifier: CredentialIssuerId,
    _ credentialIssuerMetadata: CredentialIssuerMetadata,
    _ authorizationServerMetadata: IdentityAndAccessManagementMetadata
  ) async throws -> CredentialOffer {
    return try await controller.getCredentialOffer(identifier, credentialIssuerIdentifier, credentialIssuerMetadata, authorizationServerMetadata)
  }

  func getIssuer(
    _ credentialOffer: CredentialOffer,
    _ dPoPConstructor: DPoPConstructorType?,
    _ config: OpenId4VCIConfig
  ) async throws -> Issuer {
    return try await controller.getIssuer(credentialOffer, dPoPConstructor, config)
  }

  func authorizeRequestWithAuthCodeUseCase(
    issuer: IssuerType,
    offer: CredentialOffer
  ) async throws -> AuthorizedRequest {
    return try await controller.authorizeRequestWithAuthCodeUseCase(issuer: issuer, offer: offer)
  }

  func issueCredential(
    _ issuer: Issuer,
    _ authorized: AuthorizedRequest,
    _ credentialConfigurationIdentifier: CredentialConfigurationIdentifier?
  ) async throws -> Credential {
    return try await controller.issueCredential(issuer, authorized, credentialConfigurationIdentifier)
  }
}
