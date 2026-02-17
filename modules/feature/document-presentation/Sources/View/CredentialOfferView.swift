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
import presentation_ui
import presentation_common

public struct CredentialOfferView<Router: RouterGraphType>: View {
  
  @Environment(\.localizationController) var localization
  
  @ObservedObject var viewModel: CredentialOfferViewModel<Router>
  
  @State private var showDeviceWarning = false
  @State private var isScannerPresented = false
  @State private var isGalleryPresented = false
  @State private var enableWalletAttestation = false
  
  @State private var lastOfferUri: String = ""
  @State private var transactionCodeInput: String = ""
  
  @State private var attestationSchemeSegment = 0
  @State private var selectedCredentialFormat = 0
  
  public init(with viewModel: CredentialOfferViewModel<Router>) {
    self.viewModel = viewModel
  }
  
  public var body: some View {
    NavigationView {
      ContentScreenView(
        bgColor: showDeviceWarning
        ? .yellow
        : .blue
      ) {
        List {
          if showDeviceWarning {
            Section {
              attestationWanring()
            }
          }
          
          Section(
            header: Text("Configuration")
          ){
            
            HStack {
              Picker("Credential Format", selection: $selectedCredentialFormat) {
                ForEach(CredentialFormatType.allCases) { type in
                  Text(type.displayName).tag(type.rawValue)
                }
              }
            }
            
            if selectedCredentialFormat == CredentialFormatType.sdJwt.rawValue {
              HStack {
                Picker("Attestation Type", selection: $attestationSchemeSegment) {
                  ForEach(AttestationType.allCases) { type in
                    Text(type.displayName).tag(type.rawValue)
                  }
                }
                .onChange(of: attestationSchemeSegment) { newValue in
                  withAnimation(.easeOut) {
                    if AttestationType(rawValue: newValue) == .device {
                      #if targetEnvironment(simulator)
                      showDeviceWarning = true
                      #else
                      showDeviceWarning = false
                      #endif
                    } else {
                      showDeviceWarning = false
                    }
                  }
                }
              }
            }
          }
        }
        .scrollContentBackground(.hidden)
      }
      .scrollDisabled(true)
      .navigationTitle(localization.get(with: .scanner))
      .fullScreenCover(isPresented: $isScannerPresented) {
        QRCodeScanncerView(
          onSuccess: { scannedString in
            isScannerPresented = false
            lastOfferUri = scannedString

            if selectedCredentialFormat == CredentialFormatType.mdoc.rawValue {
              return
            }
            
            await viewModel.scanAndIssueCredential(
              offerUri: scannedString,
              scope: "myScope",
              transactionCode: "",
              attestationType: attestationSchemeSegment,
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
        transactionCode()
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            if selectedCredentialFormat == CredentialFormatType.mdoc.rawValue {
              Task {
                await viewModel.issueMdocDocument()
              }
            } else {
              isScannerPresented = true
            }
          } label: {
            Image(systemName: selectedCredentialFormat == CredentialFormatType.mdoc.rawValue
                  ?  SymbolManager.value(for: .issueDocument)
                  :  SymbolManager.value(for: .qrcode)
            )
            .animation(.easeInOut,value: selectedCredentialFormat)
          }
          .disabled(showDeviceWarning)
        }
      }
    }
  }
  
  @ViewBuilder
  private func transactionCode() -> some View {
    VStack(spacing: .zero) {
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
  
  @ViewBuilder
  private func attestationWanring() -> some View {
    HStack(alignment: .top,spacing: 12){
      Image(systemName: SymbolManager.value(for: .warning))
        .font(.largeTitle)
        .foregroundStyle(.yellow)
        .symbolRenderingMode(.hierarchical)
      VStack(alignment: .leading){
        Text("Attestation Unavailable")
          .font(.headline)
        Text("Device attestation cannot be performed in the Simulator.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
}
