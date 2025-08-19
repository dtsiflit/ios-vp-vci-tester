//
//  eudi-openid4vci-ios-app
//
import Copyable

@Copyable
struct OfferScanState: ViewState { }

class OfferScanViewModel<Router: RouterGraphType>: ViewModel<Router, OfferScanState> {

  private let interactor: OfferScanInteractorType

  init(
    router: Router,
    interactor: OfferScanInteractorType
  ) {
    self.interactor = interactor
    super.init(
      router: router,
      initialState: .init()
    )
  }

  func navigateToIssuanceProgressView() {
    router.navigateTo(.issuanceProgressView)
  }
}
