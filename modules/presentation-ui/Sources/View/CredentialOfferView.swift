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

struct CredentialOfferView<Router: RouterGraphType>: View {

  @ObservedObject var viewModel: CredentialOfferViewModel<Router>
  @Environment(\.localizationController) var localization

  @State private var isGalleryPresented = false
  @State private var isScannerPresented = false
  @State private var lastOfferUri: String = ""
  @State private var transactionCodeInput: String = ""
  
  @State private var enableWalletAttestation = false
  @State private var attestationSchemeSegment = 0
  
  init(with viewModel: CredentialOfferViewModel<Router>) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      ContentScreenView {
        VStack {
          Spacer()
            .frame(width: .infinity, height: 50.0)
          Text("Attestation type")
            .frame(maxWidth: .infinity, alignment: .leading)
          Picker("What is your favorite color?", selection: $attestationSchemeSegment) {
            Text("None").tag(0)
            Text("Device").tag(1)
            Text("JWK").tag(2)
          }
          .pickerStyle(.segmented)
        }
        
        ActionCardView(
          label: localization.get(with: .credentialIssuanceCardLabel),
          description: localization.get(with: .credentialIssuanceCardDescription),
          supportingText: viewModel.viewState.supportingText,
          buttonLabel: localization.get(with: .credentialIssuanceCardButtonLabel)) {
            isScannerPresented = true
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      .navigationTitle(localization.get(with: .actions))
      .fullScreenCover(isPresented: $isScannerPresented) {
        QRCodeScanncerView(
          onSuccess: { scannedString in
            isScannerPresented = false
            lastOfferUri = scannedString
            await viewModel.scanAndIssueCredential(
              offerUri: scannedString,
              scope: "myScope",
              transactionCode: "",
              attestationType: attestationSchemeSegment
            )
          },
          onCancel: {
            isScannerPresented = false
          }
        )
      }
      .sheet(isPresented: Binding(
        get: { viewModel.viewState.needsTransactionCode },
        set: { _ in })
      ) {
        VStack(spacing: 0) {
          List {
            Section(header: Text(localization.get(with: .issuanceRequest))) {
              HStack(spacing: 15) {
                Text(localization.get(with: .transactionCode))
                TextField(localization.get(with: .fiveDigits), text: $transactionCodeInput)
                  .textFieldStyle(.plain)
              }
            }
          }
          .listStyle(.insetGrouped)
          .scrollDisabled(true)
          .scrollContentBackground(.hidden)
          .padding(.top)

          Text(localization.get(with: .submit))
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
