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

public enum CredentialPresentationError: LocalizedError {
  case rejected
  case notJwt
  case invalidPublicKey
  case invalidWebKeySet
  case unknown(reason: String)

  public var errorDescription: String? {
    switch self {
    case .rejected:
      return "Rejected"
    case .notJwt:
      return "Not JWT"
    case .invalidPublicKey:
      return "Invalid public key"
    case .invalidWebKeySet:
      return "Invalid WebKeySet"
    case .unknown(let reason):
      return "Unknown error: \(reason)"
    }
  }
}
