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
import domain_business_logic
import AuthenticationServices

protocol CredentialOfferInteractorType: Sendable {

  func issueCredential(
    offerUri: String,
    scope: String,
    transactionCode: String?
  ) async throws -> CredentialOutcome

  func requestDeferredCredential(
    deferredCredential: DeferredCredentialOutcome
  ) async throws -> CredentialOutcome

  func isPreAuthorizedGrant(
    offerUri: String,
    scope: String
  ) async throws -> Bool
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {

  private let controller: CredentialIssuanceControllerType
  private let bindingKey: BindingKey

  init(
    controller: CredentialIssuanceControllerType,
    bindingKey: BindingKey
  ) {
    self.controller = controller
    self.bindingKey = bindingKey
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
    transactionCode: String? = ""
  ) async throws -> CredentialOutcome {

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

  func requestDeferredCredential(
    deferredCredential: DeferredCredentialOutcome
  ) async throws -> CredentialOutcome {
    return try await controller.requestDeferredCredential(
      deferredCredential.issuer,
      deferredCredential.trasnactionId,
      deferredCredential
    )
    .mapToCredentialOutcome(isSDJWT: false)
  }

  private func authorizeRequestWithAuthCodeUseCase(
    issuer: Issuer,
    credentialOffer: CredentialOffer
  ) async throws -> CredentialOutcome {
    let authorized = try await controller.authorizeRequestWithAuthCodeUseCase(
      issuer: issuer,
      offer: credentialOffer
    )

    let credential = try await controller.issueCredential(
      issuer,
      authorized,
      credentialOffer.credentialConfigurationIdentifiers.first!
    )

    return await credential.mapToCredentialOutcome(
      isSDJWT: credentialOffer.isSDJWT,
      privateKey: bindingKey.privateKeyOrGenerate,
      sdJwtVc: issuer.issuerMetadata.signedMetadata
    )
  }

  private func authorizeWithPreAuthorizationCode(
    issuer: Issuer,
    credentialOffer: CredentialOffer,
    preAuthorizedCode: Grants.PreAuthorizedCode,
    transactionCode: String
  ) async throws -> CredentialOutcome {
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

    let credential = try await controller.issueCredential(
      issuer,
      auth,
      credentialOffer.credentialConfigurationIdentifiers.first!
    )

    return credential.mapToCredentialOutcome(isSDJWT: credentialOffer.isSDJWT)
  }
}

extension CredentialOffer {
  var isSDJWT: Bool {
    credentialConfigurationIdentifiers
      .contains { $0.value.contains("sd_jwt") }
  }

  var isPID: Bool {
    credentialConfigurationIdentifiers
      .contains { $0.value.contains("pid") }
  }
}
