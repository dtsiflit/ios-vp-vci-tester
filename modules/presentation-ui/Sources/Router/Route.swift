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
import domain_business_logic

public enum Route: Hashable, Identifiable, Equatable {
  case credentialOffer
  case credentialOfferResultView(config: CredentialOfferResultType)
  case deferredPendingView(credentialOutcome: CredentialOutcome)
  case credentialPresentationResult

  public var id: String {
    switch self {
    case .credentialOffer: return "credentialOffer"
    case .credentialOfferResultView: return "credentialOfferResultView"
    case .deferredPendingView: return "deferredPendingView"
    case .credentialPresentationResult: return "presentationResult"
    }
  }

  public static func == (lhs: Route, rhs: Route) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
