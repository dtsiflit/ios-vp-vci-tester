/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import DeviceCheck
import CryptoKit
import JOSESwift

public enum AppAttestClientError: Error, LocalizedError {
  case notSupported
  case keyGenerationFailed(Error?)
  case attestationFailed(Error?)
  case invalidChallenge
  case utf8Encoding
  
  public var errorDescription: String? {
    switch self {
    case .notSupported: return "App Attest is not supported on this device."
    case .keyGenerationFailed(let e): return "Failed to generate App Attest key. \(e?.localizedDescription ?? "")"
    case .attestationFailed(let e): return "Failed to create App Attest attestation. \(e?.localizedDescription ?? "")"
    case .invalidChallenge: return "Challenge was empty or missing."
    case .utf8Encoding: return "Could not UTF-8 encode challenge."
    }
  }
}

public struct AttestationResult {
  /// The App Attest key identifier returned by `DCAppAttestService.generateKey`.
  public let keyID: String
  /// The binary attestation object returned by `attestKey`.
  public let attestationObject: Data
  /// The server-provided challenge (echo back to your server if it expects it).
  public let challenge: String
  
  /// Convenience for sending to JSON APIs.
  public var attestationObjectBase64: String { attestationObject.base64EncodedString() }
  public var attestationObjectBase64URL: String { base64url(attestationObject) }
}

@inline(__always)
private func base64url(_ data: Data) -> String {
  data.base64EncodedString()
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "")
}

extension DCAppAttestService: @unchecked @retroactive Sendable {}

/// A small client that wraps App Attest calls with async/await and uses your WalletProviderClient
/// to fetch the attestation challenge.
public final class AppAttestClient: Sendable {
  
  private let deviceCheck: DCAppAttestService
  private let walletClient: WalletProviderClient
  
  public init(
    walletClient: WalletProviderClient
  ) {
    self.walletClient = walletClient
    self.deviceCheck = .shared
  }
  
  // MARK: - Step 1: Generate an App Attest key and get its keyID
  
  /// Generates an App Attest key and returns its keyID. Persist this keyID securely
  /// (e.g., Keychain) and reuse it across launches.
  public func generateKeyID() async throws -> String {
    guard deviceCheck.isSupported else { throw AppAttestClientError.notSupported }
    return try await deviceCheck.generateKey()
  }
  
  // MARK: - Step 2: Perform attestation with a server-provided challenge
  
  /// Fetches a challenge from your WalletProvider, hashes it, and requests an attestation
  /// object for the given App Attest keyID.
  ///
  /// - Parameter keyID: The App Attest key identifier (previously created via `generateKeyID()`).
  /// - Returns: `AttestationResult` containing the keyID, attestation object (binary), and the challenge.
  public func platformAttest(using keyID: String) async throws -> AttestationResult {
    guard deviceCheck.isSupported else { throw AppAttestClientError.notSupported }
    
    // 1) Get challenge from your server
    let challengeResp = try await walletClient.getChallenge()
    guard let challenge = challengeResp.challenge.nonEmpty else {
      throw AppAttestClientError.invalidChallenge
    }
    
    // 2) Hash the challenge (server and client must hash the same bytes)
    guard let challengeData = challenge.data(using: .utf8) else {
      throw AppAttestClientError.utf8Encoding
    }
    let clientDataHash = Data(SHA256.hash(data: challengeData))
    
    // 3) Ask App Attest for attestation object
    let attestationObject = try await deviceCheck.attestKey(keyID, clientDataHash: clientDataHash)
    
    return AttestationResult(
      keyID: keyID,
      attestationObject: attestationObject,
      challenge: challenge
    )
  }
  
  /// Fetches a client attestation JWT from you wallet provider.
  ///
  /// - Returns: `String` containing the wallet application attestation.
  public func jwkAttest(using payload: [String: Any]) async throws -> String {
    
    let walletInstanceAttestation = try await walletClient.issueWalletInstanceAttestationJwk(
      payload: payload
    )
    
    return walletInstanceAttestation.walletInstanceAttestation
  }
  
  public func getKeyAttestation(publicKey: SecKey, result: AttestationResult) async throws -> String {
    
    // The bytes Signum expects in CryptoPublicKey.iosEncoded (ANSI X9.63)
    let iosPoint = try base64url(exportPublicKeyX963(publicKey))//appAttestPK.iosEncodedBase64URL
    
    let clientDataJSON: [String: Any] = [
      "purpose": "ios app-attest: secure enclave protected key",
      "publicKey": iosPoint,
      "challenge": result.challenge
    ]
    
    let jwt = try await walletClient.issueWalletInstanceAttestationIos(payload: [
      "clientId": "wallet-dev",
      "keyAttestation": [
        "attestation": result.attestationObjectBase64,
        "clientDataJSON": base64URLEncodedString(from: clientDataJSON)
      ],
      "challenge": result.challenge
    ])
    
    return jwt.walletInstanceAttestation
  }
}

// MARK: - Tiny niceties

private extension String {
  var nonEmpty: String? { isEmpty ? nil : self }
}

func sha256Base64URL(from dict: [String: Any]) -> String? {
  // 1) Dictionary -> JSON data (sorted keys for deterministic output)
  guard JSONSerialization.isValidJSONObject(dict),
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
        // 2) JSON data -> JSON string
        let jsonString = String(data: jsonData, encoding: .utf8) else {
    return nil
  }
  
  // 3) JSON string -> Data (explicitly, as requested)
  let dataForHash = Data(jsonString.utf8)
  
  // 4) SHA-256 digest
  let digest = SHA256.hash(data: dataForHash)
  let digestData = Data(digest)
  
  // 5) Base64URL (replace +/ with -_ and strip =)
  var b64 = digestData.base64EncodedString()
  b64 = b64.replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "")
  return b64
}

func base64URLEncodedString(from dictionary: [String: Any]) -> String? {
  // Convert dictionary to JSON
  guard JSONSerialization.isValidJSONObject(dictionary),
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys]) else {
    return nil
  }
  
  // Standard Base64
  var base64 = jsonData.base64EncodedString()
  
  // Convert to Base64URL (RFC 4648)
  base64 = base64
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "") // remove padding
  
  return base64
}

enum X963ExportError: Error, LocalizedError {
  case notECKey
  case cfError(Error)
  case unexpectedFormat
  
  var errorDescription: String? {
    switch self {
    case .notECKey: return "Key is not an EC P-256 key."
    case .cfError(let e): return "Security framework error: \(e.localizedDescription)"
    case .unexpectedFormat: return "Exported key is not in uncompressed X9.63 format."
    }
  }
}

/// Export an EC *public* SecKey to ANSI X9.63 uncompressed bytes (0x04||X||Y).
func exportPublicKeyX963(_ publicKey: SecKey) throws -> Data {
  // Confirm key type, class, and size
  let attrs = (SecKeyCopyAttributes(publicKey) ?? .init()) as NSDictionary
  let type  = attrs[kSecAttrKeyType as String]  as? String
  let klass = attrs[kSecAttrKeyClass as String] as? String
  let size  = attrs[kSecAttrKeySizeInBits as String] as? Int
  
  guard type == (kSecAttrKeyTypeECSECPrimeRandom as String),
        klass == (kSecAttrKeyClassPublic as String),
        size == 256 else {
    throw X963ExportError.notECKey
  }
  
  var cfErr: Unmanaged<CFError>?
  guard let raw = SecKeyCopyExternalRepresentation(publicKey, &cfErr) as Data? else {
    if let err = cfErr?.takeRetainedValue() { throw X963ExportError.cfError(err) }
    throw X963ExportError.unexpectedFormat
  }
  
  guard raw.count == 65, raw.first == 0x04 else {
    throw X963ExportError.unexpectedFormat
  }
  return raw
}
