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

public struct CustomCapsuleButton: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.localizationController) var localization

  private let label: LocalizableKey
  private let color: Color
  private let style: ButtonStyle
  private let action: () -> Void

  public init(
    label: LocalizableKey,
    color: Color,
    style: ButtonStyle = .primary,
    action: @escaping () -> Void) {
    self.label = label
    self.color = color
    self.style = style
    self.action = action
  }

  public var body: some View {
    Text(localization.get(with: label))
      .foregroundStyle(style == .primary ? .white: color)
      .frame(maxWidth: .infinity)
      .padding()
      .background {
        Capsule()
          .foregroundStyle(
            style == . primary
            ? color
            : colorScheme == .dark
              ? Color(UIColor.secondarySystemBackground)
              : Color(UIColor.systemBackground)
          )
      }
      .onTapGesture {
        action()
      }
  }
}

#Preview {
  CustomCapsuleButton(
    label: .close,
    color: .green,
    style: .primary,
    action: {
      print("Action")
    }
  )
}
