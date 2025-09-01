//
//  eudi-openid4vci-ios-app
//
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
      let error = NSError(
        domain: "CredentialOffer",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: viewState.errorMessage ?? "Unknown error"]
      )
      result = .failure(error)
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
