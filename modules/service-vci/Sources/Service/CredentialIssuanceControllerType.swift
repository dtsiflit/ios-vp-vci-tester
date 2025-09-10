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
import AuthenticationServices
import domain_business_logic

public protocol CredentialIssuanceControllerType: Sendable {

  var bindingKeys: [BindingKey] { get }
  var clientConfig: OpenId4VCIConfig { get }

  func setProvider(autoPresentationProvider: AutoPresentationProvider?)

  func retrieveCredentialOffer(
    _ offerUri: String,
    _ scope: String,
    _ config: OpenId4VCIConfig
  ) async throws -> CredentialOffer

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
  ) async throws -> IssuanceOutcome

  func requestDeferredCredential(
    _ issuer: Issuer,
    _ transactionId: TransactionId,
    _ deferredCredential: DeferredCredentialOutcome
  ) async throws -> IssuanceOutcome
}

final class CredentialIssuanceController: CredentialIssuanceControllerType {

  internal let bindingKeys: [BindingKey]
  internal let clientConfig: OpenId4VCIConfig
  internal let credentialOfferRequestResolver: CredentialOfferRequestResolver
  nonisolated(unsafe) var autoPresentationProvider: AutoPresentationProvider?

  init(
    bindingKeys: [BindingKey],
    clientConfig: OpenId4VCIConfig,
    credentialOfferRequestResolver: CredentialOfferRequestResolver
  ) {
    self.bindingKeys = bindingKeys
    self.clientConfig = clientConfig
    self.credentialOfferRequestResolver = credentialOfferRequestResolver
  }

  func setProvider(autoPresentationProvider: AutoPresentationProvider?) {
    self.autoPresentationProvider = autoPresentationProvider
  }

  func retrieveCredentialOffer(
    _ offerUri: String,
    _ scope: String,
    _ config: OpenId4VCIConfig
  ) async throws -> CredentialOffer {
    let result = await credentialOfferRequestResolver.resolve(
      source: try .init(
        urlString: offerUri
      ),
      policy: config.issuerMetadataPolicy
    )
    return try result.get()
  }

  func resolveCredentialIssuerMetadata(
    _ resolver: CredentialIssuerMetadataResolver,
    _ id: CredentialIssuerId,
    _ policy: IssuerMetadataPolicy
  ) async throws -> Result<CredentialIssuerMetadata, Error> {
    switch try await resolver.resolve(
      source: .credentialIssuer(
        id
      ),
      policy: policy
    ) {
    case .success(let metadata):
      return .success(metadata)
    case .failure(let error):
      return .failure(error)
    }
  }

  func resolveAuthorizationServerMetadata(
    _ resolver: AuthorizationServerMetadataResolver,
    _ credentialIssuerMetadata: CredentialIssuerMetadata
  ) async throws -> Result<IdentityAndAccessManagementMetadata, Error> {

    guard let authorizationServer = credentialIssuerMetadata.authorizationServers?.first else {
      throw CredentialIssuanceError.missingAuthorizationServerMetadata
    }

    let authServerMetadata = await resolver.resolve(url: authorizationServer)
    return authServerMetadata
  }

  func getCredentialOffer(
    _ identifier: String,
    _ credentialIssuerIdentifier: CredentialIssuerId,
    _ credentialIssuerMetadata: CredentialIssuerMetadata,
    _ authorizationServerMetadata: IdentityAndAccessManagementMetadata
  ) async throws -> CredentialOffer {

    guard let authorizationServer = credentialIssuerMetadata.authorizationServers?.first else {
      throw CredentialIssuanceError.missingAuthorizationServerMetadata
    }

    let offer = try CredentialOffer(
      credentialIssuerIdentifier: credentialIssuerIdentifier,
      credentialIssuerMetadata: credentialIssuerMetadata,
      credentialConfigurationIdentifiers: [
        .init(value: identifier)
      ],
      grants: .authorizationCode(
        .init(
          authorizationServer: authorizationServer
        )
      ),
      authorizationServerMetadata: authorizationServerMetadata
    )
    return offer
  }

  func getIssuer(
    _ credentialOffer: CredentialOffer,
    _ dPoPConstructor: DPoPConstructorType?,
    _ config: OpenId4VCIConfig
  ) async throws -> Issuer {
    try Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: config,
      dpopConstructor: dPoPConstructor
    )
  }

  func authorizeRequestWithAuthCodeUseCase(
    issuer: IssuerType,
    offer: CredentialOffer
  ) async throws -> AuthorizedRequest {
    let parPlaced = try await issuer.prepareAuthorizationRequest(
      credentialOffer: offer
    )

    if case let .success(request) = parPlaced,
       case let .prepared(parRequested) = request {

      let unAuthorized: Result<AuthorizationRequestPrepared, Error>

      // Initialize the session.
      await setProvider(autoPresentationProvider: .init())
      let callbackURL = try await webAuthenticate(
        url: parRequested.authorizationCodeURL.url,
        callbackURLScheme: WalletConfiguration.scheme
      )

      let authorizationCode = try callbackURL.authorizationCode()

      let issuanceAuthorization: IssuanceAuthorization = .authorizationCode(authorizationCode: authorizationCode)
      unAuthorized = await issuer.handleAuthorizationCode(
        request: request,
        authorizationCode: issuanceAuthorization
      )

      switch unAuthorized {
      case .success(let request):
        let authorizedRequest = await issuer.authorizeWithAuthorizationCode(
          request: request,
          authorizationDetailsInTokenRequest: .doNotInclude
        )
        if case let .success(authorized) = authorizedRequest {
          _ = authorized.accessToken.isExpired(
            issued: authorized.timeStamp,
            at: Date().timeIntervalSinceReferenceDate
          )

          return authorized
        }

      case .failure(let error):
        throw CredentialIssuanceError.unknown(reason: error.localizedDescription)
      }

    }
    throw CredentialIssuanceError.unknown(reason: "Failed to get push authorization code request")
  }

  func issueCredential(
    _ issuer: Issuer,
    _ authorized: AuthorizedRequest,
    _ credentialConfigurationIdentifier: CredentialConfigurationIdentifier?
  ) async throws -> IssuanceOutcome {
    guard let credentialConfigurationIdentifier else {
      throw CredentialIssuanceError.missingCredentialConfigurationIdentifier
    }

    let payload: IssuanceRequestPayload = .configurationBased(
      credentialConfigurationIdentifier: credentialConfigurationIdentifier
    )

    let requestOutcome = try await issuer.requestCredential(
      request: authorized,
      bindingKeys: bindingKeys,
      requestPayload: payload
    ) {
      Issuer.createResponseEncryptionSpec($0)
    }

    switch requestOutcome {
    case .success(let request):
      switch request {
      case .success(let response):
        if let result = response.credentialResponses.first {
          switch result {
          case .deferred(let transaction):
            return .deferred(
              DeferredCredentialOutcome(
                trasnactionId: transaction,
                authorizedRequest: authorized,
                issuer: issuer
              )
            )
          case .issued(_, let credential, _, _):
            return .issued(credential)
          }
        } else {
          throw CredentialIssuanceError.failedCredentialRequest(reason: "No credential response results available")
        }
      case .invalidProof:
        throw CredentialIssuanceError.failedCredentialRequest(reason: "Although providing a proof with c_nonce the proof is still invalid")
      case .failed(let error):
        throw CredentialIssuanceError.unknown(reason: error.localizedDescription)
      }
    case .failure(let error): throw CredentialIssuanceError.unknown(reason: error.localizedDescription)
    }
  }

  func requestDeferredCredential(
    _ issuer: Issuer,
    _ transactionId: TransactionId,
    _ deferredCredential: DeferredCredentialOutcome
  ) async throws -> IssuanceOutcome {
    let requestOutcome = try await issuer.requestDeferredCredential(
      request: deferredCredential.authorizedRequest,
      transactionId: deferredCredential.trasnactionId,
      dPopNonce: nil
    )

    switch requestOutcome {
    case .success(let response):
      switch response {
      case .issued(let credential):
        return .issued(credential)
      case .issuancePending(let transaction):
        return .deferred(
          DeferredCredentialOutcome(
            trasnactionId: transaction,
            authorizedRequest: deferredCredential.authorizedRequest,
            issuer: issuer
          )
        )
      case .errored(let error, _):
        throw CredentialIssuanceError.unknown(reason: error ?? "")
      }
    case .failure(let error):
      throw CredentialIssuanceError.unknown(reason: error.localizedDescription)
    }
  }

  @MainActor
  func webAuthenticate(
    url: URL,
    callbackURLScheme: String
  ) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: callbackURLScheme
      ) {
        callbackURL,
        error in
        // The completion is not async; resume the continuation exactly once.
        if let callbackURL {
          continuation
            .resume(
              returning: callbackURL
            )
        } else {
          continuation
            .resume(
              throwing: error ?? ValidationError
                .error(
                  reason: "Web auth session finished without a callback URL."
                )
            )
        }
      }

      session.prefersEphemeralWebBrowserSession = true
      session.presentationContextProvider = autoPresentationProvider

      // Start on the main actor (UI requirement)
      let started = session.start()
      if !started {
        continuation
          .resume(
            throwing: ValidationError
              .error(
              reason: "Failed to start ASWebAuthenticationSession."
            )
          )
      }
    }
  }
}

@MainActor
public final class AutoPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    let windowScene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }

    let window = windowScene?.windows.first { $0.isKeyWindow }
    return window ?? ASPresentationAnchor()
  }
}
