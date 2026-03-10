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
import SwiftCBOR
import OpenID4VP
import service_vp
import Foundation
import OpenID4VCI
import service_vci
import MdocSecurity18013
import MdocDataModel18013
import MdocDataTransfer18013

public protocol CredentialPresentationInteractorType: Sendable {
  func loadAndPresentCredential(
    url: String,
    credential: Credential,
    privateKey: SecKey
  ) async throws -> Bool

  func loadAndPresentMdocCredential(url: String) async throws -> Bool
}

final class CredentialPresentationInteractor: CredentialPresentationInteractorType {

  private let controller: CredentialPresentationControllerType

  init(
    controller: CredentialPresentationControllerType
  ) {
    self.controller = controller
  }

  func loadAndPresentCredential(
    url: String,
    credential: Credential,
    privateKey: SecKey
  ) async throws -> Bool {
    try await controller.loadAndPresentCredential(
      using: url,
      and: credential,
      and: privateKey
    )
  }

  func loadAndPresentMdocCredential(url: String) async throws -> Bool {
    try await controller.loadAndPresentMdocCredential(
      using: url,
      vpTokenBuilder: { nonce, clientId, responseUri in
        guard let issuerSignedData = Data(
          base64URLEncoded: IssuanceConstants.cborIssuerSigned
        ) else {
          throw CredentialError.genericError
        }

        guard let privateKey = CoseKeyPrivate(
          p256: IssuanceConstants.privateKeyx963,
          privateKeyId: IssuanceConstants.docId
        ) else {
          throw CredentialError.genericError
        }

        let issuerSignedMap = [
          IssuanceConstants.docId: try IssuerSigned(data: issuerSignedData.byteArray)
        ]

        let privateKeysMap = [IssuanceConstants.docId: privateKey]

        let requestItems = [
          IssuanceConstants.docId: [
            IssuanceConstants.docType: EuPidModel.pidMandatoryElementKeys.map(RequestItem.init)
          ]
        ]

        let sessionTranscript = SessionTranscript(
          handOver: generateOpenId4VpHandover(
            clientId: clientId,
            responseUri: responseUri,
            nonce: nonce,
            jwkThumbprint: nil
          )
        )

        guard let result = try await MdocHelpers.getDeviceResponseToSend(
          deviceRequest: nil,
          issuerSigned: issuerSignedMap,
          docMetadata: [:],
          selectedItems: requestItems,
          eReaderKey: nil,
          privateKeyObjects: privateKeysMap,
          sessionTranscript: sessionTranscript,
          dauthMethod: .deviceSignature,
          unlockData: [:]
        ) else {
          throw CredentialError.genericError
        }

        let vpTokenData = Data(
          result.deviceResponse.toCBOR(options: CBOROptions()).encode()
        )

        return vpTokenData.base64URLEncodedString()
      }
    )
  }
}
