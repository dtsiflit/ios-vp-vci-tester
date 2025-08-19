//
//  eudi-openid4vci-ios-app
//
import SwiftUI

struct IssuanceProgressView<Router: RouterGraph>: View {
  var body: some View {
    ContentScreenView {
      ProgressView()
    }
  }
}

#Preview {
  IssuanceProgressView()
}
