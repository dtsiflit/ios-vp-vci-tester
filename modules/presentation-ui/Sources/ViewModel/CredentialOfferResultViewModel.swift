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
import Copyable
import OpenID4VCI
import SwiftyJSON
import service_vci

@Copyable
struct CredentialOfferResultState: ViewState {
  let config: CredentialResultConfiguration
  let presentationSucces: Bool
}

class CredentialOfferResultViewModel<Router: RouterGraphType>: ViewModel<Router, CredentialOfferResultState> {

  private let config: CredentialOfferResultType
  private let interactor: CredentialPresentationInteractorType

  init(
    router: Router,
    config: CredentialOfferResultType,
    interactor: CredentialPresentationInteractorType
  ) {
    self.config = config
    self.interactor  = interactor
    super.init(
      router: router,
      initialState: .init(
        config: config.configuration,
        presentationSucces: false
      )
    )
  }

  func dismiss() {
    if config.configuration.dismiss {
      router.pop()
    } else {
      router.navigateToRoot()
    }
  }

  func loadAndPresentCredential(using url: String) async {
    do {

      let outcome = viewState.config.credential

      guard let credential = outcome?.credential else {
        throw CredentialIssuanceError.invalidIssuanceRequest("No credential available")
      }

      guard let privateKey = outcome?.privateKey else {
        print("No private key available")
        return
      }

      let presentationSuccess = try await interactor.loadAndPresentCredential(
        url: url,
        credential: credential,
        privateKey: privateKey
      )

      setState {
        $0.copy(presentationSucces: presentationSuccess)
      }

      handleResult(presentationSuccess)

    } catch {
      print("Error: \(error)")
    }
  }

  private func handleResult(_ presentationSuccess: Bool) {
    if presentationSuccess {
      if let credential = config.configuration.credential {
        router.navigateTo(
          .credentialPresentationResult(
            config: .success(
              credential: credential,
              dismiss: false,
              stage: .presentation
            )
          )
        )
      } else {
        router.navigateTo(
          .credentialPresentationResult(
            config: .failure(
              error: "Missing credential outcome",
              dismiss: false,
              stage: .presentation
            )
          )
        )
      }
    }
  }
}
