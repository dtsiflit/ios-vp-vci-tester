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
    scope: String,
    transactionCode: String?
  ) async throws -> Result<Credential, Error>

  func isPreAuthorizedGrant(
    offerUri: String,
    scope: String
  ) async throws -> Bool
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {

  private let controller: CredentialIssuanceControllerType

  init(
    controller: CredentialIssuanceControllerType
  ) {
    self.controller = controller
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

    guard let grants = credentialOffer.grants else {
      throw CredentialIssuanceError.unknown(reason: "No grants in offer")
    }

    switch grants {
    case .authorizationCode:
      return .success(
        try await authorizeRequestWithAuthCodeUseCase(
          issuer: issuer,
          credentialOffer: credentialOffer
        )
      )
    case .preAuthorizedCode(let preAuthorizedCode):
      return .success(
        try await authorizeWithPreAuthorizationCode(
          issuer: issuer,
          credentialOffer: credentialOffer,
          preAuthorizedCode: preAuthorizedCode,
          transactionCode: transactionCode ?? ""
        )
      )
    case .both(_, let preAuthorizedCode):
      return .success(
        try await authorizeWithPreAuthorizationCode(
          issuer: issuer,
          credentialOffer: credentialOffer,
          preAuthorizedCode: preAuthorizedCode,
          transactionCode: transactionCode ?? ""
        )
      )
    }
  }

  private func authorizeRequestWithAuthCodeUseCase(
    issuer: Issuer,
    credentialOffer: CredentialOffer
  ) async throws -> Credential {
    let authorized = try await controller.authorizeRequestWithAuthCodeUseCase(
      issuer: issuer,
      offer: credentialOffer
    )

    let credential = try await controller.issueCredential(
      issuer,
      authorized,
      credentialOffer.credentialConfigurationIdentifiers.first!
    )

    return credential
  }

  private func authorizeWithPreAuthorizationCode(
    issuer: Issuer,
    credentialOffer: CredentialOffer,
    preAuthorizedCode: Grants.PreAuthorizedCode,
    transactionCode: String
  ) async throws -> Credential {
    let authResult = await issuer.authorizeWithPreAuthorizationCode(
      credentialOffer: credentialOffer,
      authorizationCode: .preAuthorizationCode(
        preAuthorizedCode: preAuthorizedCode.preAuthorizedCode ?? "",
        txCode: preAuthorizedCode.txCode
      ),
      client: .public(id: "218232426"),
      transactionCode: transactionCode
    )

    let auth = try authResult.get()

    let credential = try await controller.issueCredential(
      issuer,
      auth,
      credentialOffer.credentialConfigurationIdentifiers.first!
    )

    return credential
  }
}
