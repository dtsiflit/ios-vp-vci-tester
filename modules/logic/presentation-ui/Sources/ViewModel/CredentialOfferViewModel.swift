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
import DeviceCheck
import service_vci
import domain_business

@Copyable
struct CredentialOfferState: ViewState {
  let credential: IssuedCredentialOutcome?
  let errorMessage: String?
  let isPreAuthorized: Bool
  let needsTransactionCode: Bool
  let supportingText: String
  let attestation: String?
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
        needsTransactionCode: false,
        supportingText: "Only SD-JWT credentials are supported",
        attestation: nil
      )
    )
  }

  func scanAndIssueCredential(
    offerUri: String,
    scope: String,
    transactionCode: String,
    attestationType: Int
  ) async {
    do {
      
      let jwt: String? =  switch attestationType {
      case 0: nil
      case 1: try await self.platformAttest()
      case 2: try await self.jwkAttest()
      default: nil
      }
      
      let isPreAuth = try await interactor.isPreAuthorizedGrant(
        offerUri: offerUri,
        scope: scope
      )

      if isPreAuth {
        setState {
          $0.copy(
            isPreAuthorized: true,
            needsTransactionCode: true,
            attestation: jwt
          )
        }
        return
      } else {
        let result = try await interactor.issueCredential(
          offerUri: offerUri,
          scope: scope,
          transactionCode: nil,
          attestation: jwt
        )
        
        handleCredentialResult(result)
      }
    } catch {
      setState {
        $0.copy(
          errorMessage: error.localizedDescription
        )
      }
      navigateToIssuanceResultView()
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
        transactionCode: transactionCode,
        attestation: viewState.attestation
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
      result = .success(
        credential: credential,
        dismiss: true
      )
    } else {
      result = .failure(
        error: viewState.errorMessage ?? "Unknown error",
        dismiss: true
      )
    }

    router.navigateTo(
      .credentialOfferResultView(
        config: result
      )
    )
  }

  private func navigateToPendingDeferredView(credentialOutcome: CredentialOutcome) {
    router.navigateTo(
      .deferredPendingView(
        credentialOutcome: credentialOutcome
      )
    )
  }

  private func handleCredentialResult(_ result: CredentialOutcome) {
    if let credential = result.issuedCredential {
      setState {
        $0.copy(credential: credential)
      }
      navigateToIssuanceResultView()
    }

    if let _ = result.deferredCredential {
      setState {
        $0.copy(supportingText: "Pending credential issuance...")
      }
      navigateToPendingDeferredView(credentialOutcome: result)
    }
  }
  
  nonisolated
  func platformAttest() async throws -> String {
    if DCAppAttestService.shared.isSupported {
      return try await interactor.platformAttest()
    }
    return try await interactor.jwkAttest()
  }
  
  nonisolated
  func jwkAttest() async throws -> String {
    return try await interactor.jwkAttest()
  }
}
