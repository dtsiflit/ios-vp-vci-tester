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

@Copyable
struct CredentialOfferState: ViewState {
  let credential: Credential?
  let errorMessage: String?
  let isPreAuthorized: Bool
  let needsTransactionCode: Bool
}

class CredentialOfferViewModel<Router: RouterGraphType>: ViewModel<Router, CredentialOfferState> {
  private let interactor: CredentialOfferInteractorType

  init(
    router: Router,
    interactor: CredentialOfferInteractorType
  ) {
    self.interactor = interactor
    super.init(
      router: router,
      initialState: .init(
        credential: .none,
        errorMessage: "",
        isPreAuthorized: false,
        needsTransactionCode: false
      )
    )
  }

  func scanAndIssueCredential(
    offerUri: String,
    scope: String,
    transactionCode: String
  ) async {
    do {
      let isPreAuth = try await interactor.isPreAuthorizedGrant(
        offerUri: offerUri,
        scope: scope
      )

      if isPreAuth {
        setState {
          $0.copy(
            isPreAuthorized: true,
            needsTransactionCode: true
          )
        }
        return
      } else {
        let result = try await interactor.issueCredential(
          offerUri: offerUri,
          scope: scope,
          transactionCode: nil
        )
        handleCredentialResult(result)
      }
    } catch {
      setState {
        $0.copy(
          errorMessage: error.localizedDescription
        )
      }
    }
  }

  func continueWithTransactionCode(
    offerUri: String,
    scope: String,
    transactionCode: String
  ) async {
    do {
      let result = try await interactor.issueCredential(
        offerUri: offerUri,
        scope: scope,
        transactionCode: transactionCode
      )
      handleCredentialResult(result)
    } catch {
      setState {
        $0.copy(
          errorMessage: error.localizedDescription
        )
      }
      navigateToIssuanceResultView()
    }
  }

  private func navigateToIssuanceResultView() {
    let result: CredentialOfferResultType

    if let credential = viewState.credential {
      result = .success(credential)
    } else {
      result = .failure(viewState.errorMessage ?? "Unknown error")
    }

    router.navigateTo(.credentialOfferResultView(config: result))
  }

  private func handleCredentialResult(_ result: Result<Credential, Error>) {
    switch result {
    case .success(let credential):
      setState {
        $0.copy(credential: credential)
      }
    case .failure(let error):
      setState {
        $0.copy(errorMessage: error.localizedDescription)
      }
    }
    navigateToIssuanceResultView()
  }
}
