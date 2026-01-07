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
import SwiftUI
import OpenID4VCI
import service_vci
import domain_business

public enum CredentialStage: Sendable {
  case issuance
  case presentation
}

public struct CredentialResultConfiguration: Sendable {
  public let title: String
  public let symbolName: String
  public let symbolColor: Color
  public let description: String
  public let credential: IssuedCredentialOutcome?
  public let dismiss: Bool
}

public enum CredentialOfferResultType: Sendable {
  case success(credential: IssuedCredentialOutcome, dismiss: Bool, stage: CredentialStage = .issuance)
  case failure(error: String, dismiss: Bool, stage: CredentialStage = .issuance)

  public var configuration: CredentialResultConfiguration {
    switch self {
    case .success(let credential, let dismiss, let stage):
      return CredentialResultConfiguration(
        title: "Success",
        symbolName: SymbolManager.value(for: .success),
        symbolColor: .green,
        description: stage == .issuance
          ? "The credential was issued successfully."
          : "The credential was presented successfully.",
        credential: credential,
        dismiss: dismiss
      )
    case .failure(_, let dismiss, let stage):
      return CredentialResultConfiguration(
        title: "Error",
        symbolName: SymbolManager.value(for: .failure),
        symbolColor: .red,
        description: stage == .issuance
          ? "Oops! We couldn't issue your credential this time."
          : "Oops! We couldn't present your credential this time.",
        credential: nil,
        dismiss: dismiss
      )
    }
  }
}
