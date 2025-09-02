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

public struct CredentialOfferResultConfiguration: Sendable {
  let title: String
  let symbolName: String
  let symbolColor: Color
  let description: String
}

public enum CredentialOfferResultType: Sendable {
  case success(Credential)
  case failure(Error)

  var configuration: CredentialOfferResultConfiguration {
    switch self {
    case .success:
      return CredentialOfferResultConfiguration(
        title: "Success",
        symbolName: SymbolManager.value(for: .success),
        symbolColor: .green,
        description: "The credential was issued successfully."
      )
    case .failure:
      return CredentialOfferResultConfiguration(
        title: "Error",
        symbolName: SymbolManager.value(for: .failure),
        symbolColor: .red,
        description: "Oops! We couldn't issue your credential this time."
      )
    }
  }
}
