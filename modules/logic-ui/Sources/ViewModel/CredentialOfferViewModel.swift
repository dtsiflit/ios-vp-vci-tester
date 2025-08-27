//
//  eudi-openid4vci-ios-app
//
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
  ) async throws {
    let result = try await interactor.issueCredential(offerUri: offerUri, scope: scope)
    switch result {
    case .success(let credential):
      setState { newState in
        newState.copy(credential: credential)
      }
    case .failure(let errorMessage):
      setState { newState in
        newState.copy(errorMessage: errorMessage.localizedDescription)
      }
    }
  }

  func navigateToIssuanceProgressView() {
    router.navigateTo(.issuanceProgressView)
  }
}
