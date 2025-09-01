//
//  eudi-openid4vci-ios-app
//
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
        .padding()
    }
    .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
  }
}

#Preview {
  ContentScreenView {
    EmptyView()
  }
}
