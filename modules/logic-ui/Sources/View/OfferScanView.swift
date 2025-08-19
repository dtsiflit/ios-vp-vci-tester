//
//  eudi-openid4vci-ios-app
//
import SwiftUI

struct OfferScanView<Router: RouterGraphType>: View {

  @Environment(\.localizationController) var localization
  @ObservedObject var viewModel: OfferScanViewModel<Router>

  init(
    with viewModel: OfferScanViewModel<Router>
  ) {
    self.viewModel = viewModel
  }

  var body: some View {
    ContentScreenView {
      Button(localization.get(with: .next)) {
        viewModel.navigateToIssuanceProgressView()
      }
    }
  }
}

#Preview {
  OfferScanView(
    with: .init(
      router: MockRouterGraph(),
      interactor: MockOfferScanInteractor()
    )
  )
}
