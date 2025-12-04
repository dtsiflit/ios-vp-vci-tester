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

public enum AttestationError: Error, LocalizedError {
  case notSupported
  case keyGenerationFailed(Error?)
  case attestationFailed(Error?)
  case invalidChallenge
  case utf8Encoding
  
  public var errorDescription: String? {
    switch self {
    case .notSupported:
      return "App Attest is not supported on this device."
    case .keyGenerationFailed(let error):
      return "Failed to generate App Attest key. \(error?.localizedDescription ?? "")"
    case .attestationFailed(let error):
      return "Failed to create App Attest attestation. \(error?.localizedDescription ?? "")"
    case .invalidChallenge:
      return "Challenge was empty or missing."
    case .utf8Encoding:
      return "Could not UTF-8 encode challenge."
    }
  }
}
