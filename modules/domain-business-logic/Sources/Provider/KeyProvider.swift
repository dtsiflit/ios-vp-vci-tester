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
@preconcurrency import Foundation
import OpenID4VCI

public protocol KeyProvider: Sendable {
  var privateKey: SecKey { get }
  
  func generateECJWKKey() async throws -> ECPublicKey
  func generateRsaJWKKey() async throws -> RSAPublicKey
  func generateBindingKey() async throws -> BindingKey
  func parseBindingKey(from key: BindingKey) -> SecKey?
}

public struct KeyProviderImpl: KeyProvider {

  public let privateKey: SecKey
  
  public init() {
    privateKey = try! KeyController.generateECDHPrivateKey()
  }

  public func generateRsaJWKKey() async throws -> RSAPublicKey {
    let rsaPublicKey = try await generateRSAPublicKey()
    return try RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])
  }
  
  public func generateECJWKKey() async throws -> ECPublicKey {
    let publicKey = try KeyController.generateECDHPublicKey(from: privateKey)
    return try ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "ES256"
      ])
  }

  public func generateBindingKey() async throws -> BindingKey {

    let publicKey = try KeyController.generateECDHPublicKey(from: privateKey)
    let alg = JWSAlgorithm(.ES256)

    let publicKeyJWK = try ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ]
    )

    return .jwt(
      algorithm: alg,
      jwk: publicKeyJWK,
      privateKey: .secKey(privateKey)
    )
  }

  public func parseBindingKey(from key: BindingKey) -> SecKey? {
    switch key {
    case .jwt(_, _, let privateKeyProxy, _),
        .jwtKeyAttestation(_, _, _, let privateKeyProxy, _):
      if case let .secKey(secKey) = privateKeyProxy {
        return secKey
      }
      return nil
    case .did:
      return nil
    case .x509:
      return nil
    case .attestation:
      return nil
    @unknown default:
      return nil
    }
  }

  private func generateRSAPublicKey() async throws -> SecKey {
    let rsaPrivateKey = try await generateRSAPrivateKey()
    return try KeyController.generateRSAPublicKey(from: rsaPrivateKey)
  }

  private func generateRSAPrivateKey() async throws -> SecKey {
    try KeyController.generateRSAPrivateKey()
  }
}
