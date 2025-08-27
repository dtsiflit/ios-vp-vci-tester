//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI
import AuthenticationServices
import logic_business

protocol CredentialOfferInteractorType: Sendable {

  func issueCredential(
    offerUri: String,
    scope: String
  ) async throws -> Result<
    Credential,
    Error
  >
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {
  private let controller: CredentialIssuanceControllerType

  init(controller: CredentialIssuanceControllerType) {
    self.controller = controller
  }

  func issueCredential(
    offerUri: String,
    scope: String
  ) async throws -> Result<Credential, Error> {
    
    let config = controller.clientConfig
    let credentialOffer = try await controller.retrieveCredentialOffer(
      offerUri,
      scope,
      controller.clientConfig
    )
    
    let issuer = try await controller.getIssuer(
      credentialOffer,
      nil,
      config
    )
    
    let authorized = try await controller.authorizeRequestWithAuthCodeUseCase(issuer: issuer, offer: credentialOffer)
    
    let credential = try await controller.issueCredential(
      issuer,
      authorized,
      credentialOffer.credentialConfigurationIdentifiers.first!
    )
    
    return .success(credential)
  }

  func getCredentialOffer(
    _ identifier: String,
    _ credentialIssuerIdentifier: CredentialIssuerId,
    _ credentialIssuerMetadata: CredentialIssuerMetadata,
    _ authorizationServerMetadata: IdentityAndAccessManagementMetadata
  ) async throws -> CredentialOffer {
    return try await controller.getCredentialOffer(identifier, credentialIssuerIdentifier, credentialIssuerMetadata, authorizationServerMetadata)
  }
}
