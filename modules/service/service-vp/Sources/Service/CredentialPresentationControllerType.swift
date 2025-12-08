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
import SiopOpenID4VP
import OpenID4VCI
import domain_business

public protocol CredentialPresentationControllerType: Sendable {
  func loadAndPresentCredential(
    using url: String,
    and credential: Credential,
    and privateKey: SecKey
  ) async throws -> Bool
}

final class CredentialPresentationController: CredentialPresentationControllerType {

  private let keyProvider: KeyProvider

  public init(keyProvider: KeyProvider) {
    self.keyProvider = keyProvider
  }

  func loadAndPresentCredential(
    using url: String,
    and credential: Credential,
    and privateKey: SecKey
  ) async throws -> Bool {

    let rsaJWK = try await keyProvider.generateRsaJWKKey()

    guard let keySet = try? WebKeySet(jwk: rsaJWK) else {
      throw CredentialPresentationError.invalidWebKeySet
    }

    guard let publicKeysURL = URL(string: CredentialPresentationConfiguration.publicKeys) else {
      throw CredentialPresentationError.invalidPublicKey
    }

    let wallet: SiopOpenId4VPConfiguration = vpConfiguration(
      privateKey: privateKey,
      keySet: keySet,
      publicKeysURL: publicKeysURL
    )

    let sdk = SiopOpenID4VP(walletConfiguration: wallet)

    guard let url = URL(string: url) else {
      throw CredentialPresentationError.unknown(reason: "Invalid url")
    }

    let result = await sdk.authorize(
      url: url,
    )

    switch result {
    case .jwt(let request):
      let resolved = request
      var presentation: String?

      switch resolved {
      case .vpToken(let request):
        presentation = CredentialPresentationConfiguration.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.originalClientId,
          nonce: request.nonce,
          useSha3: false,
          privateKey: privateKey,
          credential: credential
        )
      default:
        throw CredentialPresentationError.rejected
      }

      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(presentation!)]
        ])
      )

      let response = try? AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      )

      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        return true
      default:
        throw CredentialPresentationError.rejected
      }
    default:
      throw CredentialPresentationError.notJwt
    }
  }

  private func vpConfiguration(
    privateKey: SecKey,
    keySet: WebKeySet,
    publicKeysURL: URL
  ) -> SiopOpenId4VPConfiguration {
    .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try! .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          "dev.verifier-backend.eudiw.dev": .init(
            clientId: CredentialPresentationConfiguration.clientId,
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ]),
        .x509SanDns(trust: { _ in
          true
        }),
        .x509Hash(trust: { _ in
          true
        })
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
  }
}
