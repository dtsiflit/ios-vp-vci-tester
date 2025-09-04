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
import Copyable
import OpenID4VCI
import SwiftyJSON
import service_vci

@Copyable
struct DeferredPendingState: ViewState {
  let credential: CredentialOutcome?
  let label: String
  let errorMessage: String?
}

class DeferredPendingViewModel<Router: RouterGraphType>: ViewModel<Router, DeferredPendingState> {
  private let interactor: CredentialOfferInteractorType
  private let credentialOutcome: CredentialOutcome

  init(
    router: Router,
    interactor: CredentialOfferInteractorType,
    credentialOutcome: CredentialOutcome
  ) {
    self.interactor = interactor
    self.credentialOutcome = credentialOutcome
    super.init(
      router: router,
      initialState: .init(
        credential: credentialOutcome,
        label: "Issuance Pending",
        errorMessage: nil
      )
    )
  }

  func requestDeferredCredential() async {
    if let deferredCredential = viewState.credential?.deferredCredential {
      do {
        try await Task.sleep(nanoseconds: 10_000_000_000)
        let outcome = try await interactor.requestDeferredCredential(
          deferredCredential: deferredCredential
        )

        navigateToIssuanceResultView(outcome: outcome)
      } catch {
        setState {
          $0.copy(
            errorMessage: error.localizedDescription
          )
        }
        navigateToIssuanceResultView(outcome: nil)
      }
    }
  }

  private func navigateToIssuanceResultView(outcome: CredentialOutcome?) {
    let result: CredentialOfferResultType

    if let credential = outcome?.credential {
      result = .success(credential)
    } else {
      result = .failure(viewState.errorMessage ?? "Unknown error")
    }

    router.navigateTo(
      .credentialOfferResultView(
        config: result
      )
    )
  }
}

