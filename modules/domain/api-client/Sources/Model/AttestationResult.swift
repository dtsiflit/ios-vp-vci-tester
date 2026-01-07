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

public struct AttestationResult: Sendable {
  public let keyID: String
  public let attestationObject: Data
  public let challenge: String
  
  public var attestationObjectBase64: String {
    attestationObject.base64EncodedString()
  }
  
  public var attestationObjectBase64URL: String {
    base64url(attestationObject)
  }
  
  public init(keyID: String, attestationObject: Data, challenge: String) {
    self.keyID = keyID
    self.attestationObject = attestationObject
    self.challenge = challenge
  }
  
  private func base64url(_ data: Data) -> String {
    data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
  }
}
