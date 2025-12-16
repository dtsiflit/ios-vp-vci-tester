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
import OpenID4VCI
import service_vci
import domain_business
import AuthenticationServices
import api

public protocol CredentialOfferInteractorType: Sendable {

  func issueCredential(
    offerUri: String,
    scope: String,
    transactionCode: String?,
    attestation: String?
  ) async throws -> CredentialOutcome

  func requestDeferredCredential(
    deferredCredential: DeferredCredentialOutcome
  ) async throws -> CredentialOutcome

  func isPreAuthorizedGrant(
    offerUri: String,
    scope: String
  ) async throws -> Bool
  
  func platformAttest() async throws -> String
  func jwkAttest() async throws -> String
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {

  private let keyProvider: KeyProvider
  private let controller: CredentialIssuanceControllerType
  private let attestationClient: AttestationClientType
  
  init(
    keyProvider: KeyProvider,
    controller: CredentialIssuanceControllerType,
    attestationClient: AttestationClientType
  ) {
    self.keyProvider = keyProvider
    self.controller = controller
    self.attestationClient = attestationClient
  }

  func platformAttest() async throws -> String {
    
    let privateKey = keyProvider.privateKey
    let keyID = try await attestationClient.generateKeyID()
    let result = try await attestationClient.platformAttest(using: keyID)
    
    let jwt = try await attestationClient.getKeyAttestation(
      publicKey: try KeyController.generateECDHPublicKey(
        from: privateKey
      ),
      result: result
    )
    
    return jwt
  }
  
  func jwkAttest() async throws -> String {
    return try await attestationClient.jwkAttest(using: [
      "clientId": controller.clientConfig.client.id,
      "jwk": keyProvider.generateECJWKKey().toDictionary()
    ])
  }
  
  func isPreAuthorizedGrant(offerUri: String, scope: String) async throws -> Bool {
    let credentialOffer = try await controller.retrieveCredentialOffer(
      offerUri,
      scope,
      controller.clientConfig
    )

    guard let grants = credentialOffer.grants else { return false }

    switch grants {
    case .authorizationCode:
      return false
    case .preAuthorizedCode:
      return true
    case .both:
      return true
    }
  }

  func issueCredential(
    offerUri: String,
    scope: String,
    transactionCode: String? = "",
    attestation: String?
  ) async throws -> CredentialOutcome {

    let config: VCIConfig = if let attestation {
      .init(
        client: 
          .attested(
            attestationJWT: try .init(
              jws: .init(
                compactSerialization: attestation
              )
            ),
            popJwtSpec: try .init(
              signingAlgorithm: .ES256,
              duration: 300.0,
              typ: "oauth-client-attestation-pop+jwt",
              signingKey: .secKey(keyProvider.privateKey)
            )
          ),
        authFlowRedirectionURI: controller.clientConfig.authFlowRedirectionURI,
        authorizeIssuanceConfig: controller.clientConfig.authorizeIssuanceConfig,
        clientAttestationPoPBuilder: DefaultClientAttestationPoPBuilder.default
      )
    } else {
      controller.clientConfig
    }

    let credentialOffer = try await controller.retrieveCredentialOffer(
      offerUri,
      scope,
      config
    )

    let issuer = try await controller.getIssuer(
      credentialOffer,
      nil,
      config
    )

    guard let grants = credentialOffer.grants else {
      throw CredentialIssuanceError.unknown(reason: "No grants in offer")
    }

    switch grants {
    case .authorizationCode:
      return try await authorizeRequestWithAuthCodeUseCase(
        issuer: issuer,
        credentialOffer: credentialOffer
      )
    case .preAuthorizedCode(let preAuthorizedCode):
      return try await authorizeWithPreAuthorizationCode(
        issuer: issuer,
        credentialOffer: credentialOffer,
        preAuthorizedCode: preAuthorizedCode,
        transactionCode: transactionCode ?? ""
      )
    case .both(_, let preAuthorizedCode):
      return try await authorizeWithPreAuthorizationCode(
        issuer: issuer,
        credentialOffer: credentialOffer,
        preAuthorizedCode: preAuthorizedCode,
        transactionCode: transactionCode ?? ""
      )
    }
  }

  func requestDeferredCredential(deferredCredential: DeferredCredentialOutcome) async throws -> CredentialOutcome {
    return try await controller.requestDeferredCredential(
      deferredCredential.issuer,
      deferredCredential.trasnactionId,
      deferredCredential,
      deferredCredential.isSDJWT,
      deferredCredential.privateKey
    )
    .mapToCredentialOutcome(
      isSDJWT: deferredCredential.isSDJWT,
      privateKey: deferredCredential.privateKey
    )
  }

  private func authorizeRequestWithAuthCodeUseCase(
    issuer: Issuer,
    credentialOffer: CredentialOffer
  ) async throws -> CredentialOutcome {

    // Authorize
    let authorized = try await controller.authorizeRequestWithAuthCodeUseCase(
      issuer: issuer,
      offer: credentialOffer
    )

    // Generate binding key
    let bindingKey = try await keyProvider.generateBindingKey()

    guard let privateKey = keyProvider.parseBindingKey(from: bindingKey) else {
      throw CredentialError.issuerDoesNotSupportDeferredIssuance
    }

    // Issue credential
    let credential = try await controller.issueCredential(
      issuer,
      authorized,
      credentialOffer.credentialConfigurationIdentifiers.first!,
      [bindingKey],
      credentialOffer.isSDJWT,
      privateKey
    )

    return credential.mapToCredentialOutcome(
      isSDJWT: credentialOffer.isSDJWT,
      privateKey: privateKey
    )
  }

  private func authorizeWithPreAuthorizationCode(
    issuer: Issuer,
    credentialOffer: CredentialOffer,
    preAuthorizedCode: Grants.PreAuthorizedCode,
    transactionCode: String
  ) async throws -> CredentialOutcome {

    // Authorize
    let authResult = await issuer.authorizeWithPreAuthorizationCode(
      credentialOffer: credentialOffer,
      authorizationCode: .preAuthorizationCode(
        preAuthorizedCode: preAuthorizedCode.preAuthorizedCode ?? "",
        txCode: preAuthorizedCode.txCode
      ),
      client: controller.clientConfig.client,
      transactionCode: transactionCode
    )
    let auth = try authResult.get()

    // Generate binding key
    let bindingKey = try await keyProvider.generateBindingKey()

    guard let privateKey = keyProvider.parseBindingKey(from: bindingKey) else {
      throw CredentialError.issuerDoesNotSupportDeferredIssuance
    }

    // Issue credential
    let credential = try await controller.issueCredential(
      issuer,
      auth,
      credentialOffer.credentialConfigurationIdentifiers.first!,
      [bindingKey],
      credentialOffer.isSDJWT,
      privateKey
    )

    return credential.mapToCredentialOutcome(
      isSDJWT: credentialOffer.isSDJWT,
      privateKey: privateKey
    )
  }
}

extension CredentialOffer {
  var isSDJWT: Bool {
    credentialConfigurationIdentifiers
      .contains { $0.value.contains("sd_jwt") }
  }
}
