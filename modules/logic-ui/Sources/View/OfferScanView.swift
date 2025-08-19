//
//  eudi-openid4vci-ios-app
//
import SwiftUI

struct OfferScanView<Router: RouterGraphType>: View {

  @ObservedObject var viewModel: OfferScanViewModel<Router>

  init(
    with viewModel: OfferScanViewModel<Router>
  ) {
    self.viewModel = viewModel
  }

  var body: some View {
    ContentScreenView {
      Button("Next View") {
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
