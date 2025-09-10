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
import OpenID4VCI

public struct CredentialOutcome: Sendable {
  public let issuedCredential: IssuedCredentialOutcome?
  public let deferredCredential: DeferredCredentialOutcome?

  public init(
    issuedCredential: IssuedCredentialOutcome? = nil,
    deferredCredential: DeferredCredentialOutcome? = nil
  ) {
    self.issuedCredential = issuedCredential
    self.deferredCredential = deferredCredential
  }
}

public enum IssuanceOutcome {
  case issued(Credential)
  case deferred(DeferredCredentialOutcome)
}

public extension IssuanceOutcome {
  func mapToCredentialOutcome(isSDJWT: Bool) -> CredentialOutcome {
    switch self {
    case .issued(let credential):
      return .init(issuedCredential: .init(credential: credential, isSDJWT: isSDJWT))
    case .deferred(let transaction):
      return .init(deferredCredential: transaction)
    }
  }
}
