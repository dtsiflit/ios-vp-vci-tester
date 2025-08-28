//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import CodeScanner

struct CredentialOfferView<Router: RouterGraphType>: View {

  @ObservedObject var viewModel: CredentialOfferViewModel<Router>
  @Environment(\.localizationController) var localization

  @State private var isGalleryPresented = false
  @State private var isScannerPresented = false

  init(with viewModel: CredentialOfferViewModel<Router>) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      ContentScreenView {
        ActionCardView(
          isScannerPresented: .constant(true),
          icon: SymbolManager.value(for: .qrcode),
          label: localization.get(with: .credentialIssuanceCardLabel),
          description: localization.get(with: .credentialIssuanceCardDescription),
          buttonLabel: localization.get(with: .credentialIssuanceCardButtonLabel)) {
            isScannerPresented = true
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      .navigationTitle(localization.get(with: .actions))
      .fullScreenCover(isPresented: $isScannerPresented) {
        ZStack(alignment: .top) {
          CodeScannerView(
            codeTypes: [.qr],
            scanMode: .once,
            isGalleryPresented: .constant(false)
          ) { result in
            switch result {
            case .success(let scanResult):
              Task {
                isScannerPresented = false
                await viewModel.scanAndIssueCredential(
                  offerUri: scanResult.string,
                  scope: "myScope"
                )
              }
            case .failure(let error):
              print(error)
              isScannerPresented = false
            }
          }
          .ignoresSafeArea()

          Image(systemName: SymbolManager.value(for: .close))
            .font(.callout)
            .fontWeight(.medium)
            .padding(8)
            .background {
              Circle()
                .fill(.ultraThinMaterial)
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            .padding(.horizontal)
            .onTapGesture {
              isScannerPresented = false
            }
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
