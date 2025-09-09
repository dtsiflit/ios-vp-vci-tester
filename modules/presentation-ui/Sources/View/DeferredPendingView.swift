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
import OpenID4VCI
import service_vci

struct DeferredPendingView<Router: RouterGraphType>: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.localizationController) var localization

  @ObservedObject private var viewModel: DeferredPendingViewModel<Router>

  init(with viewModel: DeferredPendingViewModel<Router>) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      ContentScreenView(bgColor: .orange) {
        VStack {
          VStack(spacing: 20) {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
              .scaleEffect(2.0)
              .tint(Color.blue)
              .frame(height: 120)

            VStack(spacing: 4) {
              Text(viewModel.viewState.title)
                .font(.largeTitle)
                .fontWeight(.semibold)

              Text(viewModel.viewState.supportingText)
                .font(.title)
                .fontWeight(.semibold)
            }
          }
          .frame(maxHeight: .infinity)

          Text(localization.get(with: .close))
            .foregroundStyle(Color.gray)
            .frame(maxWidth: .infinity)
            .padding()
            .background {
              Capsule()
                .foregroundStyle(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            }
            .onTapGesture {
              dismiss()
            }
        }
        .task {
          await viewModel.requestDeferredCredential()
        }
      }
    }
    .navigationBarBackButtonHidden()
  }
}
