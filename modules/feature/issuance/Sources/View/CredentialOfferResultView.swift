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
import Foundation
import OpenID4VCI
import presentation_ui
import presentation_common

public struct CredentialOfferResultView<Router: RouterGraphType>: View {

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.localizationController) var localization

  @ObservedObject private var viewModel: CredentialOfferResultViewModel<Router>

  @State private var isScannerPresented = false
  @State private var lastPresentationURL: String = ""

  public init(with viewModel: CredentialOfferResultViewModel<Router>) {
    self.viewModel = viewModel
  }

  public var body: some View {
    NavigationView {
      ContentScreenView(bgColor: viewModel.viewState.config.symbolColor) {
        VStack {
          VStack(spacing: 20) {
            Image(systemName: viewModel.viewState.config.symbolName)
              .foregroundStyle(viewModel.viewState.config.symbolColor)
              .symbolRenderingMode(.hierarchical)
              .font(.system(size: 120))

            VStack(spacing: 4) {
              Text(viewModel.viewState.config.title)
                .font(.largeTitle)
                .fontWeight(.semibold)

              Text(viewModel.viewState.config.description)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            }
          }
          .frame(maxHeight: .infinity)

          VStack {
            if let isSDJWT = viewModel.viewState.config.credential?.isSDJWT, isSDJWT {
              CustomCapsuleButton(
                label: .presentation,
                color: viewModel.viewState.config.symbolColor) {
                  isScannerPresented = true
                }
            }

            CustomCapsuleButton(
              label: .close,
              color: viewModel.viewState.config.symbolColor,
              style: .secondary
            ) {
              viewModel.dismiss()
            }
          }
        }
      }
      .fullScreenCover(isPresented: $isScannerPresented) {
        QRCodeScanncerView(
          onSuccess: { scannedString in
            isScannerPresented = false
            lastPresentationURL = scannedString
            await viewModel.loadAndPresentCredential(using: lastPresentationURL)
          },
          onCancel: {
            isScannerPresented = false
          }
        )
      }
    }
    .navigationBarBackButtonHidden()
  }
}
