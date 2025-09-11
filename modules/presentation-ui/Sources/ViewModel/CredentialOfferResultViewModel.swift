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
struct CredentialOfferResultState: ViewState {
  let config: CredentialOfferResultConfiguration
  let presentationSucces: Bool
}

class CredentialOfferResultViewModel<Router: RouterGraphType>: ViewModel<Router, CredentialOfferResultState> {

  private let config: CredentialOfferResultType
  private let interactor: PresentationInteractorType

  init(
    router: Router,
    config: CredentialOfferResultType,
    interactor: PresentationInteractorType
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

  func loadAndPresentDocument(url: String) async {
    do {
      let presentationSucces = try await interactor.loadAndPresentDocument(url: url)
      setState {
        $0.copy(
          presentationSucces: presentationSucces
        )
      }
      handleResult(presentationSucces)
    } catch {
      print("Error")
    }
  }

  private func handleResult(_ presentationSuccess: Bool) {
    if presentationSuccess {
      router.navigateTo(.presentationResult)
    }
  }
}
