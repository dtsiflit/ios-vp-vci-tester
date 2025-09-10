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

public enum LocalizableKey: Sendable, Equatable, Hashable {

  case custom(String)
  case actions
  case close
  case credentialIssuanceCardLabel
  case credentialIssuanceCardDescription
  case credentialIssuanceCardButtonLabel
  case successIssuanceResultTitle
  case successIssuanceResultDescription
  case failureIssuanceResultTitle
  case failureIssuanceResultDescription
  case issuancePending

  func defaultTranslation(args: [String]) -> String {
    let value = switch self {
    case .custom(let literal): literal
    case .actions:
      "Actions"
    case .credentialIssuanceCardLabel:
      "Issue Credential"
    case .credentialIssuanceCardDescription:
      "Tap to open the QR code scanner to issue your credential."
    case .close:
      "Close"
    case .credentialIssuanceCardButtonLabel:
      "Open Scanner"
    case .successIssuanceResultTitle:
      "Success"
    case .successIssuanceResultDescription:
      "The credential was issued successfully."
    case .failureIssuanceResultTitle:
      "Error"
    case .failureIssuanceResultDescription:
      "Oops! We couldn't issue your credential this time."
    case .issuancePending:
      "Issuance Pending"
    }
    return value.format(arguments: args)
  }
}
