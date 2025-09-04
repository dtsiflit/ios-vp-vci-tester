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

  private let icon: String
  private let label: String
  private let description: String
  private let buttonLabel: String
  private let action: () -> Void

  public init(
    icon: String,
    label: String,
    description: String,
    buttonLabel: String,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.label = label
    self.description = description
    self.buttonLabel = buttonLabel
    self.action = action
  }

  public var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .foregroundStyle(.gray.opacity(0.1))
        .frame(height: 180)
        .overlay {
          Image(systemName: icon)
            .font(.system(size: 100))
            .foregroundStyle(LinearGradient(
              colors: [.cyan, .blue],
              startPoint: .top,
              endPoint: .bottom
            ))
        }

      VStack(alignment: .leading, spacing: 5) {
        Text(label)
          .font(.title3)
          .fontWeight(.semibold)

        Text(description)
          .foregroundStyle(.gray)

        Button(action: action) {
          Text(buttonLabel)
            .fontWeight(.medium)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.blue)
                .opacity(0.18)
            )
        }
        .padding(.top, 15)
        .contentShape(RoundedRectangle(cornerRadius: 12))

        Text("Only SD-JWT credentials containing PID are supported.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(.top, 10)
          .padding(.bottom, 5)
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .background(
      colorScheme == .dark
      ? Color(UIColor.secondarySystemBackground)
      : Color(UIColor.systemBackground)
    )
    .frame(maxWidth: .infinity)
    .clipShape(RoundedRectangle(cornerRadius: 26))
  }
}

#Preview {
  ActionCardView(
    icon: SymbolManager.issuance.rawValue,
    label: "Credential Offer",
    description: "Scan the QR code provided to receive your credential securely.",
    buttonLabel: "Open Scanner") {
      print("Action")
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .secondarySystemBackground))
}
