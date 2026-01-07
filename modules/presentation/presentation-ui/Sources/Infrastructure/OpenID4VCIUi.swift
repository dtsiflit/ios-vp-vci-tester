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
import domain_business

public final actor OpenID4VCIUi { }

public extension OpenID4VCIUi {
  enum State: Equatable, Sendable {

    case none
    case credentialOffer
    case credentialOfferResultView(credential: CredentialOfferResultType)
    case deferredPendingView(credentialOutcome: CredentialOutcome)

    public var id: String {
      return switch self {
      case .none:
        "none"
      case .credentialOffer:
        "credentialOffer"
      case .credentialOfferResultView:
        "credentialOfferResultView"
      case .deferredPendingView:
        "deferredPendingView"
      }
    }

    public static func == (lhs: State, rhs: State) -> Bool {
      return lhs.id == rhs.id
    }
  }
}
