//
//  eudi-openid4vci-ios-app
//
import SwiftUI

struct ContentScreenView<Content: View>: View {

  private let content: Content

  init(
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
  }

  var body: some View {
    VStack {
      content
    }
  }
}

#Preview {
  ContentScreenView {
    EmptyView()
  }
}
