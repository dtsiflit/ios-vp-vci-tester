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
import SwiftUI
import CodeScanner

struct CredentialOfferView<Router: RouterGraphType>: View {

  @ObservedObject var viewModel: CredentialOfferViewModel<Router>
  @Environment(\.localizationController) var localization

  @State private var isGalleryPresented = false
  @State private var isScannerPresented = false
  @State private var lastOfferUri: String = ""
  @State private var transactionCodeInput: String = ""

  init(with viewModel: CredentialOfferViewModel<Router>) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      ContentScreenView {
        ActionCardView(
          isScannerPresented: .constant(true),
          icon: SymbolManager.value(for: .issuance),
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
                lastOfferUri = scanResult.string
                await viewModel.scanAndIssueCredential(
                  offerUri: scanResult.string,
                  scope: "myScope",
                  transactionCode: ""
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
      .sheet(isPresented: Binding(
        get: { viewModel.viewState.needsTransactionCode },
        set: { _ in })
      ) {
        VStack(spacing: 0) {
          List {
            Section(header: Text("Issuance Request")) {
              HStack(spacing: 15) {
                Text("Transaction Code")
                TextField("5-digit code", text: $transactionCodeInput)
                  .textFieldStyle(.plain)
              }
            }
          }
          .listStyle(.insetGrouped)
          .scrollDisabled(true)
          .scrollContentBackground(.hidden)
          .padding(.top)

          Text("Submit")
            .frame(maxWidth: .infinity)
            .disabled(transactionCodeInput.isEmpty)
            .foregroundStyle(.white)
            .padding(15)
            .background {
              RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(transactionCodeInput.isEmpty ? .gray.opacity(0.28) : .blue)
            }
            .animation(.easeInOut, value: transactionCodeInput)
            .frame(maxWidth: .infinity)
            .onTapGesture {
              Task {
                await viewModel.continueWithTransactionCode(
                  offerUri: lastOfferUri,
                  scope: "myScope",
                  transactionCode: transactionCodeInput
                )
              }
            }
            .padding(.horizontal)
            .padding()
        }
        .presentationDetents([.height(190)])
        .keyboardType(.numberPad)
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
