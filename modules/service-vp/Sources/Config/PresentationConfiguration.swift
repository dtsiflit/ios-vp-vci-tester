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
import SiopOpenID4VP

public struct CredentialPresentationConfiguration {

  static let clientId = "dev.verifier-backend.eudiw.dev"
  static let publicKeys = "https://dev.verifier-backend.eudiw.dev/wallet/public-keys.json"
  static let sdJwtVcPid = "eyJ4NWMiOlsiTUlJQzZ6Q0NBcEdnQXdJQkFnSVViWDhuYllTTFJ2eTEwbUtOK2hmQ1ZyLzhjQmN3Q2dZSUtvWkl6ajBFQXdJd1hERWVNQndHQTFVRUF3d1ZVRWxFSUVsemMzVmxjaUJEUVNBdElGVlVJREF5TVMwd0t3WURWUVFLRENSRlZVUkpJRmRoYkd4bGRDQlNaV1psY21WdVkyVWdTVzF3YkdWdFpXNTBZWFJwYjI0eEN6QUpCZ05WQkFZVEFsVlVNQjRYRFRJMU1EUXhNREUwTWpVME1Gb1hEVEkyTURjd05ERTBNalV6T1Zvd1VqRVVNQklHQTFVRUF3d0xVRWxFSUVSVElDMGdNRE14TFRBckJnTlZCQW9NSkVWVlJFa2dWMkZzYkdWMElGSmxabVZ5Wlc1alpTQkpiWEJzWlcxbGJuUmhkR2x2YmpFTE1Ba0dBMVVFQmhNQ1ZWUXdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBU3J4WjEzd0xqL25VdUdlYllSbVBPMHE3cFJrMXgxU2pycUxUdnRRRnBRY3k5VHdGQ2NnaWUvQkJDMmovS3BMY0NyK29qNHR5WkFvZm12SGRhVEV4YkJvNElCT1RDQ0FUVXdId1lEVlIwakJCZ3dGb0FVWXNlVVJ5aTlENklXSUtlYXdrbVVSUEVCMDhjd0p3WURWUjBSQkNBd0hvSWNaR1YyTG1semMzVmxjaTFpWVdOclpXNWtMbVYxWkdsM0xtUmxkakFXQmdOVkhTVUJBZjhFRERBS0JnZ3JnUUlDQUFBQkFqQkRCZ05WSFI4RVBEQTZNRGlnTnFBMGhqSm9kSFJ3Y3pvdkwzQnlaWEJ5YjJRdWNHdHBMbVYxWkdsM0xtUmxkaTlqY213dmNHbGtYME5CWDFWVVh6QXlMbU55YkRBZEJnTlZIUTRFRmdRVWNzM0t5cWl6SGd0WFJlMzJuNkpCSkhBZmFMWXdEZ1lEVlIwUEFRSC9CQVFEQWdlQU1GMEdBMVVkRWdSV01GU0dVbWgwZEhCek9pOHZaMmwwYUhWaUxtTnZiUzlsZFMxa2FXZHBkR0ZzTFdsa1pXNTBhWFI1TFhkaGJHeGxkQzloY21Ob2FYUmxZM1IxY21VdFlXNWtMWEpsWm1WeVpXNWpaUzFtY21GdFpYZHZjbXN3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUlnVFZabmNoRCtRanE1M1hzMG9jMDd5M3pHNmtBWEZrSitaS3psVkcyMnNDOENJUUR0RE1RcTBRbS9mUTVvcnJqUlQ0WEIrMEpiNnhGUHhYOVFrVlJhTXkvSWlBPT0iXSwia2lkIjoiNjI1MTE1NjIzMzA2MTIyNDk0ODA5Njg1MDI2ODI2NDM5OTAyMzM0MDY5NTM0NzQzIiwidHlwIjoiZGMrc2Qtand0IiwiYWxnIjoiRVMyNTYifQ.eyJfc2QiOlsiLUpCZ085TGNyZGlkWnF3VmVCRWJzX0hIaUdqV1B1ZzN6dHR4aldLZ2w0RSIsIi1ZVEo0MFpLd1h0VnhPeXcxRGpjMVVXZFdVUW8xdUhVbm5DVmlRR0tKamciLCI2elNDTERNY1NFTWh0N2FHbm4zZ04yQ2g0Rkx0VEFRY2EteWdGVXNGOGZ3IiwiOGI3VERrSnlTeTBrNnN3cDFUVmFUY1YyQl9uSkFjbDBTSVhEcnlDSi1vayIsIjhwaUhTTmVFVDR2UGRDWnFSQlRub2w0OW5jcmVZRmQzZDhHbk5lM0U1OUkiLCJCblFWQ0Z5cTVwaFhOTldWZE02cEpKU1Nidl8wZGo4Z09IRkg2ZWxTaU93IiwiSEp5NEI1WTJNZ2xjQUhycjFfWUVYMzI5UmhHQW9jaHZQNUVnRDJnWDVyVSIsIkhpTTFyVVVMYVBoS1NQMjRvU1dQdW41b0VLemhpZmJXZF9mYWtUdUxGWnciLCJNY0hDZ0xMcm8tRlhoVS05LU9fdVV6ZS04NThTZkktbFZWUmZtOFYtRXlFIiwiV3JGYzVaZXpsSHhEMnhmMzlCTFBPcGFYOURXdm15cGdNOWE2eU11TTZZYyIsImJ1ajR1UUxBQ3RzVzJQeTlhTlZldmV6elYyTFVXYndYOXZ2WXRLRk5nb00iLCJjc2dtX2ZPUnRvM0lhbU45dmNzVzR1YktndTk3Zmd4M0JhS1ZYVFBhMjVVIiwibG9pQ080YkFTRlhQOXdZLUpVbzJrRTZFZy1DRVlhbDMzWEU4QzJ5RWhORSIsIm11cTlNWXNLaVBlaU51NnVzSXE3U3lib0tpcHZDWjQ0N2tsZzhqMF9wRTgiLCJub2hDd2xHU3NMYUhMdE1lVWx4N1pSeXhwX3FSTVdDdjl5N2IzNlVFeGQ0IiwicU5nWVpDZ0lQU2tSbXBid2pOOFo1VUJqdktTRVdobVNETVlfWXF5ZEo1dyIsInQwMXV1WGxWNmNKUWpGRFZDQl9GeG5RbEhxRWdjam05QnJVY1VoS0djS2MiLCJ1ZEItM1U2QnRWbDV6VlViRFV5RV9lX2FxOG52SW1Wb19meWJSd0ZkX3FRIiwid3FhMjdLUlhrNkp6UVlRcF9NakhKdnJBSS0xR0kzUWNubXRPdi1wcTJrZyIsInhYSlNyNGpNNEhqbXJzc3psZHNVb3RlaF9vazFjdHppRTgzYXFWVmNhOWciXSwidmN0IjoidXJuOmV1ZGk6cGlkOjEiLCJfc2RfYWxnIjoic2hhLTI1NiIsImlzcyI6Imh0dHBzOi8vZGV2Lmlzc3Vlci1iYWNrZW5kLmV1ZGl3LmRldiIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJ1c2UiOiJzaWciLCJjcnYiOiJQLTI1NiIsImtpZCI6IjQ2ZmI5MjM2LTdjZTEtNDFlYi04Y2FjLWUzNDRlMWQ4ZTkxZSIsIngiOiJHaWJLYkkxZW1mQ0VMUjdyTmRfaFZON0s3QzQ4cHdiOFV2QUREeFY1ODlzIiwieSI6Imx6ZXgwZzZMYmd0V3FLWkgzSlJ5VWJPSnRDOHZtRGNmWDJPWGwxTDhIYVUiLCJpYXQiOjE3NTI0OTI1NjF9fSwiZXhwIjoxODE1NTY0NTY2LCJpYXQiOjE3NTI0OTI1NjYsInN0YXR1cyI6eyJzdGF0dXNfbGlzdCI6eyJpZHgiOjIyNDAsInVyaSI6Imh0dHBzOi8vaXNzdWVyLmV1ZGl3LmRldi90b2tlbl9zdGF0dXNfbGlzdC9GQy91cm46ZXVkaTpwaWQ6MS8xMjQ4MDg0My1kMTFhLTQzNWEtYTQ1OS02YWI2MjI2Nzc1MzUifX19.VaeKHmeB2IBWmJMLOBeVJMR5uEQVhNL1ldQGRhqbllVe6qMukuf-7y5i9ES32iUekgOlePb1HWk5-7hsDQxcMw~WyJFWlFScEpwRFRIdWpZOEFjUG95RlBRIiwiZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJ1T2VvXzhobS1YdW1ibXRwYl9xc2tnIiwiZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJub0lxM2RBMkIySjZPeE5aU3RGSmZRIiwiYmlydGhkYXRlIiwiMTk1NS0wNC0xMiJd~WyJKUUEyTVJEa29zMEN6S0RieDZlUzdBIiwiY291bnRyeSIsIkFUIl0~WyJlSGJuc0xFYUNsZy1sY2hWMDRXeVJBIiwibG9jYWxpdHkiLCIxMDEgVHJhdW5lciJd~WyJlS29CbGI0azctZHhoenFLTFhzVHB3IiwicGxhY2Vfb2ZfYmlydGgiLHsiX3NkIjpbIklKOU5qcnFONHp4Wjh5X1N5V0EwSDJJazk2VTRReUpDTHB2ODVkY0VHaDQiLCJjbGZnem5mQXotSkc5b2hnTkJ1cVNWdEdMY1MwQXN4d3EzQnRsNGlvVDFZIl19XQ~WyJkZ1RwOFBnX3JCX3R4cWFNTnU5eUhnIiwiQVQiXQ~WyJ5NWZIamhLZXRvblB4aDZnSS1IZnNRIiwibmF0aW9uYWxpdGllcyIsW3siLi4uIjoiaExyNUxxNHp5YmNRaW1wRzJFWnJYTldmRHNGWFRZdDVPRG5WMU15dVpKNCJ9XV0~WyJHWE4xUnFEb25DLXZibjVBNndmNzlRIiwiaG91c2VfbnVtYmVyIiwiMTAxICJd~WyJQcUE0d0tZZl9mTmJBZXRkako2dmpRIiwic3RyZWV0X2FkZHJlc3MiLCJUcmF1bmVyIl0~WyJKVFczaXBTQ3ZzVjdNMDBuRThtaDZ3IiwibG9jYWxpdHkiLCJHZW1laW5kZSBCaWJlcmJhY2giXQ~WyJPS3VpcWJWcUdXR0xNSVpaWlVwUnZ3IiwicmVnaW9uIiwiTG93ZXIgQXVzdHJpYSJd~WyJwWGNHajZMN01MMHdVS3NuSldtRlVRIiwicG9zdGFsX2NvZGUiLCIzMzMxIl0~WyJHSGkwVUNkcUtidV9mLU0zcXlicmZRIiwiY291bnRyeSIsIkFUIl0~WyJtVDhxd2pBUkUtNy1qZzNSUVFRYWt3IiwiYWRkcmVzcyIseyJfc2QiOlsiQ3Yxak9GNlB0QmVxUVFUV3NFd3ZCek9vZVJVNVBsYnFXX3FxbWl4cWlhSSIsIkYtN3RJTmdFQndoTTFuUFl4SXFCeEdDNW8taUs5NHFBN3Y4WjBBOHBjQTAiLCJ1V2wzV3JrYTN0QV9TSlc4em5VLXhRSHRnclUtRURSTzRsOU5JWlBNdzhvIiwiam1LaUU0MGU0VnZyWnlLbXJ2b21Ma3hVLWtQUHM5cGlEc0JISDZnTHlZbyIsIlFyYUJFX2RpN3RMY0FvalZKLWpGU05ieGdYUzBvcWZtaWhOdWJ3ZUtibmciLCJiZk42TktCVlRCQVFGaXhMbjlxaG1UcENsQ24zZUs4R3IwOXNEV2d1WHBBIl19XQ~WyJ3a0ZjeWdOQ19qbVJmQWs4VGxPd3FnIiwicGVyc29uYWxfYWRtaW5pc3RyYXRpdmVfbnVtYmVyIiwiMDgxNTJjNjMtNTgyOC00NTU0LWI4YWUtOWI0YTEwZjQ3YjBkIl0~WyJQdGdxZnZubjhJS2w4a3RQbS1RWVBBIiwiYmlydGhfZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJVQ3pwX1c4aFEySWRPUmFtelJlYk13IiwiYmlydGhfZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyIwVGthbWJhVmZSWllVblFWdVpodklRIiwic2V4IiwxXQ~WyI5SXFLcnVnaHhsaXVzSVNISTdCd0p3IiwiZW1haWwiLCJ0eWxlci5uZWFsQGV4YW1wbGUuY29tIl0~WyI5QUY0ZjZFRDVpbHJBOTNrb1ItWk1BIiwiMTgiLHRydWVd~WyJlUC1mNDVwNGtocWdGT0ZEbG5ieUx3IiwiYWdlX2VxdWFsX29yX292ZXIiLHsiX3NkIjpbInFIQUNQT0U0UXM0bFphdmpUYzBUaTZaOXBHSzBjSkdZWEpvZFNoYmtNZW8iXX1d~WyItanJSWHlGbzNPSkJiQV9KSW5RaU9BIiwiYWdlX2luX3llYXJzIiw3MV0~WyIzcHpLTXBwNjQwM1NmSkJ6U1VXdFJRIiwiYWdlX2JpcnRoX3llYXIiLCIxOTU1Il0~WyJCcWxXUHN0aXVVaU1rcERqY0RYMVhnIiwiZGF0ZV9vZl9leHBpcnkiLCIyMDI1LTEwLTIyIl0~WyJJMWNkRHBSTUJWMGd3bVBkaENXN3BnIiwiaXNzdWluZ19hdXRob3JpdHkiLCJHUiBBZG1pbmlzdHJhdGl2ZSBhdXRob3JpdHkiXQ~WyJ4TFN6Y2pvNUZKd1ZrOGNOVlE5Z0FnIiwiaXNzdWluZ19jb3VudHJ5IiwiR1IiXQ~WyJROHpGTWZxbVVkQXQxY0wxa3RlTnBRIiwiZG9jdW1lbnRfbnVtYmVyIiwiY2E1MDdjMTQtMWUyOS00Zjg1LWFmZDUtMjNjZGRjYTVkOGM2Il0~WyJBUldOdjEtcHZibjFBektIa3Vrd2dRIiwiaXNzdWluZ19qdXJpc2RpY3Rpb24iLCJHUi1JIl0~WyJzczRoYUxEQTVfWDJERDUycGl0UnNBIiwiZGF0ZV9vZl9pc3N1YW5jZSIsIjIwMjUtMDctMTQiXQ~"

  static func sdJwtPresentations(
    transactiondata: [TransactionData]?,
    clientID: String,
    nonce: String,
    useSha3: Bool = true,
    privateKey: SecKey,
    sdJwtVc: String
  ) -> String {
    let sdHash = useSha3 ? sha3_256Hash(sdJwtVcPid) : sha256Hash(sdJwtVcPid)

    return try! generateVerifiablePresentation(
      sdJwtVc: sdJwtVc,
      audience: clientID,
      nonce: nonce,
      sdHash: sdHash,
      transactionData: transactiondata,
      privateKey: privateKey
    )
  }

  static func sha3_256Hash(_ input: String) -> String {
    let inputData = Array(input.utf8)
    let digest = SHA3(variant: .sha256).calculate(for: inputData)
    return Data(digest).base64URLEncodedString()
  }

  static func sha256Hash(_ input: String) -> String {
    let inputData = Array(input.utf8)
    let digest = SHA256.hash(data: inputData)
    return Data(digest).base64URLEncodedString()
  }

  static func generateVerifiablePresentation(
    sdJwtVc: String,
    audience: String,
    nonce: String,
    sdHash: String,
    transactionData: [TransactionData]?,
    privateKey: SecKey
  ) throws -> String {

    // Create JWT Header
    let header = try! JWSHeader(
      parameters: [
        "alg": "ES256",
        "typ": "kb+jwt"
      ]
    )

    // Prepare claims
    var claims: [String: Any] = [
      "aud": audience,
      "nonce": nonce,
      "iat": Int(Date().timeIntervalSince1970) - 100,
      "sd_hash": sdHash
    ]

    // Process transaction data hashes if available
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

    // Create JWT Payload
    let payloadData = try! JSONSerialization.data(
      withJSONObject: claims,
      options: []
    )
    let payload = Payload(payloadData)

    // Sign JWT
    // Create and Sign JWT Using JoseSwift
    let jws = try JWS(
      header: header,
      payload: payload,
      signer: Signer(
        signatureAlgorithm: .ES256,
        key: privateKey
      )!
    )
    let keyBindingJwt = jws.compactSerializedString
    return "\(sdJwtVc)\(keyBindingJwt)"
  }
}
