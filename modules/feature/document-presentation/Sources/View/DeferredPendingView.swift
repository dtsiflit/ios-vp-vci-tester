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
import presentation_ui
import presentation_common

public struct DeferredPendingView<Router: RouterGraphType>: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.localizationController) var localization

  @ObservedObject private var viewModel: DeferredPendingViewModel<Router>

  public init(with viewModel: DeferredPendingViewModel<Router>) {
    self.viewModel = viewModel
  }

  public var body: some View {
    NavigationView {
      ContentScreenView(bgColor: .orange) {
        ProgressView(localization.get(with: .pendingIssuance))
          .progressViewStyle(CircularProgressViewStyle(tint: .orange))
          .task {
            await viewModel.requestDeferredCredential()
          }
      }
    }
    .navigationBarBackButtonHidden()
  }
}
