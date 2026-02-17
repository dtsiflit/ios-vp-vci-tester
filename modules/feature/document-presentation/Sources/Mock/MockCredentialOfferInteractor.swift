/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import Foundation
import OpenID4VCI
import SwiftyJSON
import domain_business

public final class MockCredentialOfferInteractor: CredentialOfferInteractorType {

  public init() {}

  public func isPreAuthorizedGrant(offerUri: String, scope: String) async throws -> Bool {
    return false
  }

  public func issueCredential(offerUri: String, scope: String, transactionCode: String?, attestation: String?) async -> CredentialOutcome {
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
    let credentialOutcome = CredentialOutcome(issuedCredential: .init(credential: mockCredential))
    return credentialOutcome
  }

  func retrieveCredentialOffer(
    _ offerUri: String,
    _ scope: String,
    _ config: OpenId4VCIConfig
  ) async throws -> CredentialOffer {
    throw ValidationError.todo(reason: "Implement soon")
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
  
  public func issueMdocDocument() async throws -> String {
    throw ValidationError.todo(reason: "Implement soon")
  }

  public func requestDeferredCredential(
    deferredCredential: DeferredCredentialOutcome
  ) async throws -> CredentialOutcome {
    throw ValidationError.todo(reason: "Implement soon")
  }
  
  public func platformAttest() async throws -> String {
    throw ValidationError.todo(reason: "Implement soon")
  }
  
  public func jwkAttest() async throws -> String {
    throw ValidationError.todo(reason: "Implement soon")
  }
}
