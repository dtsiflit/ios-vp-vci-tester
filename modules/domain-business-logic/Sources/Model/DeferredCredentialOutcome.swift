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
@preconcurrency import Security

public struct DeferredCredentialOutcome: Sendable {
  public let trasnactionId: TransactionId
  public let authorizedRequest: AuthorizedRequest
  public let issuer: Issuer
  public let isSDJWT: Bool
  public let privateKey: SecKey

  public init(
    trasnactionId: TransactionId,
    authorizedRequest: AuthorizedRequest,
    issuer: Issuer,
    isSDJWT: Bool,
    privateKey: SecKey
  ) {
    self.trasnactionId = trasnactionId
    self.authorizedRequest = authorizedRequest
    self.issuer = issuer
    self.isSDJWT = isSDJWT
    self.privateKey = privateKey
  }
}

public struct IssuedCredentialOutcome: Sendable {
  public let credential: Credential
  public let privateKey: SecKey?
  public let isSDJWT: Bool

  public init(
    credential: Credential,
    privateKey: SecKey? = nil,
    isSDJWT: Bool = false
  ) {
    self.credential = credential
    self.privateKey = privateKey
    self.isSDJWT = isSDJWT
  }
}
