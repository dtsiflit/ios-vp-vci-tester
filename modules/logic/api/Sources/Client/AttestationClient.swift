/*
 * Copyright (c) 2025 European Commission
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
import DeviceCheck
import CryptoKit

extension DCAppAttestService: @unchecked @retroactive Sendable {}

public protocol AttestationClientType: Sendable {
  func generateKeyID() async throws -> String
  func platformAttest(using keyID: String) async throws -> AttestationResult
  func jwkAttest(using payload: [String: Any]) async throws -> String
  func getKeyAttestation(publicKey: SecKey,result: AttestationResult) async throws -> String
}

final class AttestationClient: AttestationClientType {
  
  private let deviceCheck: DCAppAttestService
  private let repository: AttestationRepositoryType
  
  public init(repository: AttestationRepositoryType) {
    self.repository = repository
    self.deviceCheck = .shared
  }
  
  public func generateKeyID() async throws -> String {
    guard deviceCheck.isSupported else {
      throw AttestationError.notSupported
    }
    
    do {
      return try await deviceCheck.generateKey()
    } catch {
      throw AttestationError.keyGenerationFailed(error)
    }
  }
  
  public func platformAttest(using keyID: String) async throws -> AttestationResult {
    guard deviceCheck.isSupported else {
      throw AttestationError.notSupported
    }
    
    // 1. Get challenge from server
    let emptyPayload = Data()
    let challengeResp = try await repository.getChallenge(payload: emptyPayload)
    
    guard let challenge = challengeResp.challenge.nonEmpty else {
      throw AttestationError.invalidChallenge
    }
    
    // 2. Hash the challenge
    guard let challengeData = challenge.data(using: .utf8) else {
      throw AttestationError.utf8Encoding
    }
    let clientDataHash = Data(SHA256.hash(data: challengeData))
    
    // 3. Request attestation from Apple
    do {
      let attestationObject = try await deviceCheck.attestKey(
        keyID,
        clientDataHash: clientDataHash
      )
      
      return AttestationResult(
        keyID: keyID,
        attestationObject: attestationObject,
        challenge: challenge
      )
    } catch {
      throw AttestationError.attestationFailed(error)
    }
  }
  
  public func jwkAttest(using payload: [String: Any]) async throws -> String {
    let payloadData = try JSONSerialization.data(
      withJSONObject: payload,
      options: [.sortedKeys]
    )
    
    let attestation = try await repository.issueWalletInstanceAttestationJwk(
      payload: payloadData
    )
    
    return attestation.walletInstanceAttestation
  }
  
  public func getKeyAttestation(
    publicKey: SecKey,
    result: AttestationResult
  ) async throws -> String {
    
    let iosPoint = try base64url(exportPublicKeyX963(publicKey))
    
    let clientDataJSON: [String: Any] = [
      "purpose": "ios app-attest: secure enclave protected key",
      "publicKey": iosPoint,
      "challenge": result.challenge
    ]
    
    let payload: [String: Any] = [
      "clientId": "wallet-dev",
      "keyAttestation": [
        "attestation": result.attestationObjectBase64,
        "clientDataJSON": base64URLEncodedString(from: clientDataJSON) ?? ""
      ],
      "challenge": result.challenge
    ]
    
    let payloadData = try JSONSerialization.data(
      withJSONObject: payload,
      options: [.sortedKeys]
    )
    
    let jwt = try await repository.issueWalletInstanceAttestationIos(
      payload: payloadData
    )
    
    return jwt.walletUnitAttestation
  }
  
  func base64url(_ data: Data) -> String {
      data.base64EncodedString()
          .replacingOccurrences(of: "+", with: "-")
          .replacingOccurrences(of: "/", with: "_")
          .replacingOccurrences(of: "=", with: "")
  }

  func base64URLEncodedString(from dictionary: [String: Any]) -> String? {
      guard JSONSerialization.isValidJSONObject(dictionary),
            let jsonData = try? JSONSerialization.data(
              withJSONObject: dictionary,
              options: [.sortedKeys]
            ) else {
          return nil
      }
      
      return base64url(jsonData)
  }

  func sha256Base64URL(from dict: [String: Any]) -> String? {
      guard JSONSerialization.isValidJSONObject(dict),
            let jsonData = try? JSONSerialization.data(
              withJSONObject: dict,
              options: [.sortedKeys]
            ) else {
          return nil
      }
      
      let digest = SHA256.hash(data: jsonData)
      let digestData = Data(digest)
      return base64url(digestData)
  }
  
  func exportPublicKeyX963(_ publicKey: SecKey) throws -> Data {
      let attrs = (SecKeyCopyAttributes(publicKey) ?? .init()) as NSDictionary
      let type = attrs[kSecAttrKeyType as String] as? String
      let klass = attrs[kSecAttrKeyClass as String] as? String
      let size = attrs[kSecAttrKeySizeInBits as String] as? Int
      
      guard type == (kSecAttrKeyTypeECSECPrimeRandom as String),
            klass == (kSecAttrKeyClassPublic as String),
            size == 256 else {
          throw X963ExportError.notECKey
      }
      
      var cfErr: Unmanaged<CFError>?
      guard let raw = SecKeyCopyExternalRepresentation(publicKey, &cfErr) as Data? else {
          if let err = cfErr?.takeRetainedValue() {
              throw X963ExportError.cfError(err)
          }
          throw X963ExportError.unexpectedFormat
      }
      
      guard raw.count == 65, raw.first == 0x04 else {
          throw X963ExportError.unexpectedFormat
      }
      
      return raw
  }
}
