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

struct ContentScreenView<Content: View>: View {

  @Environment(\.colorScheme) var colorScheme

  private let bgColor: Color
  private let content: Content

  init(
    bgColor: Color = .blue,
    @ViewBuilder content: () -> Content
  ) {
    self.bgColor = bgColor
    self.content = content()
  }

  var body: some View {
    ZStack {
      Rectangle()
        .foregroundStyle( LinearGradient(
          colors: [
            bgColor.opacity(0.3),
            .clear,
            .clear,
            .clear
          ],
          startPoint: .top,
          endPoint: .bottom
        ))
        .ignoresSafeArea()

      content
        .padding(.horizontal)
        .padding(.top, 10)
    }
    .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
  }
}

#Preview {
  ContentScreenView {
    EmptyView()
  }
}
