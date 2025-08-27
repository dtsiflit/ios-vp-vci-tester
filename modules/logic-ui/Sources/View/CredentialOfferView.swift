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
          try await viewModel.scanAndIssueCredential(
            offerUri: "openid-credential-offer://credential_offer?credential_offer=%7B%22credential_issuer%22:%20%22https://dev.issuer.eudiw.dev%22%2C%20%22credential_configuration_ids%22:%20%5B%22eu.europa.ec.eudi.pid_mdoc%22%5D%2C%20%22grants%22:%20%7B%22urn:ietf:params:oauth:grant-type:pre-authorized_code%22:%20%7B%22pre-authorized_code%22:%20%22d366d6a4-aa2a-485a-9fcd-922d9834a9c5%22%2C%20%22tx_code%22:%20%7B%22length%22:%205%2C%20%22input_mode%22:%20%22numeric%22%2C%20%22description%22:%20%22Please%20provide%20the%20one-time%20code.%22%7D%7D%7D%7D",
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
