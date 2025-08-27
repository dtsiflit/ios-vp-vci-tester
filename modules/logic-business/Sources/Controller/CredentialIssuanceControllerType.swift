//
//  eudi-openid4vci-ios-app
//
import Foundation
import AuthenticationServices
import OpenID4VCI

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
  ) async throws -> Credential
}

final class CredentialIssuanceController: CredentialIssuanceControllerType {

  internal let bindingKeys: [BindingKey]
  internal let clientConfig: OpenId4VCIConfig
  nonisolated(unsafe) var autoPresentationProvider: AutoPresentationProvider?
  
  init(
    bindingKeys: [BindingKey],
    clientConfig: OpenId4VCIConfig
  ) {
    self.bindingKeys = bindingKeys
    self.clientConfig = clientConfig
  }

  func setProvider(autoPresentationProvider: AutoPresentationProvider?) {
    self.autoPresentationProvider = autoPresentationProvider
  }
  
  func retrieveCredentialOffer(
    _ offerUri: String,
    _ scope: String,
    _ config: OpenId4VCIConfig
  ) async throws -> CredentialOffer {
    let result = await CredentialOfferRequestResolver()
      .resolve(
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
      return .failure(ValidationError.error(reason: "Missing authorization server metadata"))
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
      throw ValidationError.error(reason: "Missing authorization server metadata")
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
      let authorizationCode: String

      let scheme = "eudi-openid4ci"

      // Initialize the session.
      await setProvider(autoPresentationProvider: .init())
      let callbackURL = try await awaitWebAuthCallback(
        url: parRequested.authorizationCodeURL.url,
        callbackURLScheme: scheme
      )

      if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
         let queryItems = urlComponents.queryItems,
         let codeItem = queryItems.first(where: { $0.name == "code" }),
         let code = codeItem.value {

        authorizationCode = code
      } else {
        throw ValidationError.error(reason: "Authorization code not found in callback URL")
      }

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
        throw  ValidationError.error(reason: error.localizedDescription)
      }

    }
    throw ValidationError.error(reason: "Failed to get push authorization code request")
  }

  func issueCredential(
    _ issuer: Issuer,
    _ authorized: AuthorizedRequest,
    _ credentialConfigurationIdentifier: CredentialConfigurationIdentifier?
  ) async throws -> Credential {
    guard let credentialConfigurationIdentifier else {
      throw ValidationError.error(reason: "Credential configuration identifier not found")
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
          case .deferred:
            throw ValidationError.todo(reason: "Deferred Issuance case")
          case .issued(_, let credential, _, _):
            return credential
          }
        } else {
          throw ValidationError.error(reason: "No credential response results available")
        }
      case .invalidProof:
        throw ValidationError.error(reason: "Although providing a proof with c_nonce the proof is still invalid")
      case .failed(let error):
        throw ValidationError.error(reason: error.localizedDescription)
      }
    case .failure(let error): throw ValidationError.error(reason: error.localizedDescription)
    }
  }

  @MainActor
  func awaitWebAuthCallback(
    url: URL,
    callbackURLScheme: String
  ) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: callbackURLScheme
      ) { callbackURL, error in
        // The completion is not async; resume the continuation exactly once.
        if let callbackURL {
          continuation.resume(returning: callbackURL)
        } else {
          // Prefer the original AS error if present; otherwise make a generic one.
          continuation.resume(throwing: error ?? NSError(
            domain: "ASWebAuthenticationSession",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Web auth session finished without a callback URL."]
          ))
        }
      }

      session.prefersEphemeralWebBrowserSession = true
      session.presentationContextProvider = autoPresentationProvider

      // Start on the main actor (UI requirement)
      let started = session.start()
      if !started {
        continuation.resume(throwing: NSError(
          domain: "ASWebAuthenticationSession",
          code: -2,
          userInfo: [NSLocalizedDescriptionKey: "Failed to start ASWebAuthenticationSession."]
        ))
      }
    }
  }
}

@MainActor
public final class AutoPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding, Sendable {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    // Try the active key window from any connected scene
    if let window = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow }) {
      return window
    }

    // Fallback: a visible window if any
    if let window = UIApplication.shared.windows.first(where: { $0.isHidden == false }) {
      return window
    }

    // As a last resort, create a temporary window (not ideal, but prevents start() from failing)
    let temp = UIWindow(frame: UIScreen.main.bounds)
    temp.isHidden = false
    return temp
  }
}
