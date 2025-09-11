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

public protocol KeyProvider: Sendable {
  func generateECDHPrivateKey() async throws -> SecKey
  func generateRsaJWKKey() async throws -> RSAPublicKey
}

public struct KeyProviderImpl: KeyProvider {

  public init() {}

  public func generateECDHPrivateKey() async throws -> SecKey {
    try KeyController.generateECDHPrivateKey()
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

  private func generateRSAPublicKey() async throws -> SecKey {
    let rsaPrivateKey = try await generateRSAPrivateKey()
    return try KeyController.generateRSAPublicKey(from: rsaPrivateKey)
  }

  private func generateRSAPrivateKey() async throws -> SecKey {
    try KeyController.generateRSAPrivateKey()
  }
}
