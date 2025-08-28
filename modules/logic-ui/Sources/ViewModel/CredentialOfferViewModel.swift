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
        errorMessage: ""
      )
    )
  }

  func scanAndIssueCredential(
    offerUri: String,
    scope: String
  ) async {
    do {
      let result = try await interactor.issueCredential(offerUri: offerUri, scope: scope)
      switch result {
      case .success(let credential):
        setState {
          $0.copy(
            credential: credential
          )
        }

        navigateToIssuanceResultView()
      case .failure(let errorMessage):
        setState {
          $0.copy(
            errorMessage: errorMessage.localizedDescription
          )
        }
      }
    } catch {
      setState {
        $0.copy(
          errorMessage: error.localizedDescription
        )
      }
    }
  }

  func navigateToIssuanceResultView() {
      let result: CredentialOfferResultType

      if let credential = viewState.credential {
          result = .success(credential)
      } else if let errorMessage = viewState.errorMessage, !errorMessage.isEmpty {
          let error = NSError(domain: "CredentialOffer", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
          result = .failure(error)
      } else {
          let error = NSError(domain: "CredentialOffer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
          result = .failure(error)
      }

    router.navigateTo(.credentialOfferResultView(config: result))
  }
}
