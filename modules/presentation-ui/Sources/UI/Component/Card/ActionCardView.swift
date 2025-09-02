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

public struct ActionCardView: View {

  @Environment(\.colorScheme) var colorScheme

  @Binding var isScannerPresented: Bool

  private let icon: String
  private let label: String
  private let description: String
  private let buttonLabel: String
  private let action: () -> Void

  public init(
    isScannerPresented: Binding<Bool>,
    icon: String,
    label: String,
    description: String,
    buttonLabel: String,
    action: @escaping () -> Void
  ) {
    self._isScannerPresented = isScannerPresented
    self.icon = icon
    self.label = label
    self.description = description
    self.buttonLabel = buttonLabel
    self.action = action
  }

  public var body: some View {
    HStack(alignment: .top, spacing: 15) {
      Image(systemName: icon)
        .font(.largeTitle)
        .foregroundStyle(.blue)

      VStack(alignment: .leading, spacing: 5) {
        Text(label)
          .fontWeight(.semibold)

        Text(description)
          .foregroundStyle(.gray)

        Button(buttonLabel) {
          action()
        }
        .fontWeight(.medium)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background {
          Capsule()
            .foregroundStyle(.blue)
            .opacity(0.18)
        }
        .padding(.top, 10)
      }
    }
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .padding()
    .background {
      RoundedRectangle(cornerRadius: 26)
        .foregroundStyle(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  ActionCardView(
    isScannerPresented: .constant(true),
    icon: "qrcode.viewfinder",
    label: "Credential Offer",
    description: "Scan the QR code provided to receive your credential securely.",
    buttonLabel: "Open Scanner") {
      print("Action")
    }
}
