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
import JOSESwift
import CryptoKit
import CryptoSwift
import OpenID4VP
import OpenID4VCI

public struct CredentialPresentationConfiguration {

  static let clientId = "dev.verifier-backend.eudiw.dev"
  static let publicKeys = "https://dev.verifier-backend.eudiw.dev/wallet/public-keys.json"

  static func sdJwtPresentations(
    transactiondata: [TransactionData]?,
    clientID: String,
    nonce: String,
    useSha3: Bool = true,
    privateKey: SecKey,
    credential: Credential
  ) -> String? {

    let credentialString: String

    switch credential {
    case .string(let str):
      credentialString = str
    case .json(let json):
      credentialString = json[0]["credential"].string ?? "{}"
    }

    let sdHash = useSha3 ? sha3_256Hash(credentialString) : sha256Hash(credentialString)

    return try? generateVerifiablePresentation(
      audience: clientID,
      nonce: nonce,
      sdHash: sdHash,
      transactionData: transactiondata,
      privateKey: privateKey,
      credential: credential
    )
  }

  private static func generateVerifiablePresentation(
    audience: String,
    nonce: String,
    sdHash: String,
    transactionData: [TransactionData]?,
    privateKey: SecKey,
    credential: Credential
  ) throws -> String? {

    guard let header = try? JWSHeader(
      parameters: [
        "alg": "ES256",
        "typ": "kb+jwt"
      ]
    ) else {
      throw CredentialPresentationError.unknown(reason: "Not valid jws header")
    }

    var claims: [String: Any] = [
      "aud": audience,
      "nonce": nonce,
      "iat": Int(Date().timeIntervalSince1970) - 100,
      "sd_hash": sdHash
    ]

    if let transactionData = transactionData, !transactionData.isEmpty {
      let hashAlgorithm = "sha-256"
      let transactionDataHashes = transactionData.compactMap {
        switch $0 {
        case .sdJwtVc(let value):
          return sha256Hash(value)
        }
      }
      claims["transaction_data_hashes_alg"] = hashAlgorithm
      claims["transaction_data_hashes"] = transactionDataHashes
    }

    let payloadData = try? JSONSerialization.data(
      withJSONObject: claims,
      options: []
    )

    if let payloadData, let singer = Signer(
      signatureAlgorithm: .ES256,
      key: privateKey
    ) {
      let payload = Payload(payloadData)

      let jws = try JWS(
        header: header,
        payload: payload,
        signer: singer
      )

      let keyBindingJwt = jws.compactSerializedString

      let credentialContent: String
      switch credential {
      case .string(let str):
        credentialContent = str
      case .json(let json):
        credentialContent = json[0]["credential"].string ?? "{}"
      }

      return "\(credentialContent)\(keyBindingJwt)"
    }

    return nil
  }

  private static func sha3_256Hash(_ input: String) -> String {
    let inputData = Array(input.utf8)
    let digest = SHA3(variant: .sha256).calculate(for: inputData)
    return Data(digest).base64URLEncodedString()
  }

  private static func sha256Hash(_ input: String) -> String {
    let inputData = Array(input.utf8)
    let digest = SHA256.hash(data: inputData)
    return Data(digest).base64URLEncodedString()
  }
}
