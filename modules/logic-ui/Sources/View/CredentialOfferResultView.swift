//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import OpenID4VCI

struct CredentialOfferResultView: View {

  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.localizationController) var localization

  private let config: CredentialOfferResultConfiguration

  init(for result: CredentialOfferResultType) {
    self.config = result.configuration
  }

  var body: some View {
    NavigationView {
      ContentScreenView(bgColor: config.symbolColor) {
        VStack {
          VStack(spacing: 20) {
            Image(systemName: config.symbolName)
              .foregroundStyle(config.symbolColor)
              .symbolRenderingMode(.hierarchical)
              .font(.system(size: 120))

            VStack(spacing: 4) {
              Text(config.title)
                .font(.largeTitle)
                .fontWeight(.semibold)

              Text(config.description)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            }
          }
          .frame(maxHeight: .infinity)

          Text(localization.get(with: .close))
            .foregroundStyle(config.symbolColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background {
              Capsule()
                .foregroundStyle(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            }
            .onTapGesture {
              dismiss()
            }
        }
      }
    }
    .navigationBarBackButtonHidden()
  }
}

#Preview {
  CredentialOfferResultView(
    for: .success(.string(""))
  )
}
