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

  private let label: String
  private let description: String
  private let buttonLabel: String
  private let supportingText: String
  private let action: () -> Void

  public init(
    label: String,
    description: String,
    supportingText: String,
    buttonLabel: String,
    action: @escaping () -> Void
  ) {
    self.label = label
    self.description = description
    self.buttonLabel = buttonLabel
    self.supportingText = supportingText
    self.action = action
  }

  public var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 5) {
        Text(label)
          .font(.title3)
          .fontWeight(.semibold)

        Text(description)
          .foregroundStyle(.gray)
          .font(.callout)

        Button(action: action) {
          Text(buttonLabel)
            .fontWeight(.medium)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              Capsule()
                .foregroundStyle(.blue)
                .opacity(0.18)
            )
        }
        .padding(.top, 15)
        .contentShape(Capsule())

        Text(supportingText)
          .font(.caption)
          .foregroundStyle(.secondary)
          .padding(.top, 10)
          .padding(.bottom, 5)
      }
      .padding(20)
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
    label: "Credential Offer",
    description: "Scan the QR code provided to receive your credential securely.",
    supportingText: "Only SD-JWT credentials are supported.",
    buttonLabel: "Open Scanner") {
      print("Action")
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .secondarySystemBackground))
}
