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
import JOSESwift
import Foundation
import SiopOpenID4VP

public protocol CredentialPresentationControllerType: Sendable {
  func loadAndPresentCredential(using url: String) async throws -> Bool
}

final class CredentialPresentationController: CredentialPresentationControllerType {

  func loadAndPresentCredential(using url: String) async throws -> Bool {

    let rsaPrivateKey = try! KeyController.generateRSAPrivateKey()
    let rsaPublicKey = try! KeyController.generateRSAPublicKey(from: rsaPrivateKey)
    let privateKey = try! KeyController.generateECDHPrivateKey()

    let rsaJWK = try! RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])

    let keySet = try! WebKeySet(jwk: rsaJWK)
    let publicKeysURL = URL(string: "https://dev.verifier-backend.eudiw.dev/wallet/public-keys.json")!

    let wallet: SiopOpenId4VPConfiguration = .init(
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
            clientId: "dev.verifier-backend.eudiw.dev",
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ]),
        .x509SanDns(trust: { _ in
          true
        })
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )

    let sdk = SiopOpenID4VP(walletConfiguration: wallet)

    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )

    switch result {
    case .jwt(let request):

      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(CredentialPresentationConfiguration.cbor)]
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
}
