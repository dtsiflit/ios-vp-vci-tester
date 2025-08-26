//
//  eudi-openid4vci-ios-app
//
import SwiftUI

struct CredentialOfferView<Router: RouterGraphType>: View {

  @Environment(\.localizationController) var localization
  @ObservedObject var viewModel: CredentialOfferViewModel<Router>

  init(
    with viewModel: CredentialOfferViewModel<Router>
  ) {
    self.viewModel = viewModel
  }

  var body: some View {
    ContentScreenView {
      Button("Scan QR & Issue Credential") {
        Task {
          await viewModel.scanAndIssueCredential(
            offerUri: "https://issuer.example/offer/123",
            scope: "myScope"
          )
        }
      }

      if let credential = viewModel.viewState.credential {
        Group {
          switch credential {
          case .string(let value):
            Text("Credential (string): \(value)")
              .foregroundColor(.green)
              .padding()
          case .json(let json):
            Text("Credential (json):\n\(json.rawString(options: .prettyPrinted) ?? "")")
              .font(.system(.footnote, design: .monospaced))
              .foregroundColor(.blue)
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
          }
        }
        .padding(.top)
      }
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        Button(localization.get(with: .next)) {
          viewModel.navigateToIssuanceProgressView()
        }
      }
    }
  }
}

#Preview {
  CredentialOfferView(
    with: .init(
      router: MockRouterGraph(),
      interactor: MockCredentialOfferInteractor()
    )
  )
}
