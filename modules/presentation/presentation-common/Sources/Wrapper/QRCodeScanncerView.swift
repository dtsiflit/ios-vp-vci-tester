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
import presentation_ui

public struct QRCodeScanncerView: View {

  private let onSuccess: (String) async -> Void
  private let onCancel: (() -> Void)?

  public init(
    onSuccess: @escaping (String) async -> Void,
    onCancel: (() -> Void)? = nil
  ) {
    self.onSuccess = onSuccess
    self.onCancel = onCancel
  }

  public var body: some View {
    ZStack(alignment: .top) {
      CodeScannerView(
        codeTypes: [.qr],
        scanMode: .once,
        isGalleryPresented: .constant(false)
      ) { result in
        switch result {
        case .success(let scanResult):
          Task {
            await onSuccess(scanResult.string)
          }
        case .failure(let error):
          print(error)
          onCancel?()
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
          onCancel?()
        }
    }
  }
}

#Preview {
  QRCodeScanncerView { _ in
    print("Action")
  }
}
