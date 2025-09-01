//
//  eudi-openid4vci-ios-app
//
import SwiftUI
import domain_business_logic

protocol LocalizationControllerType: Sendable {
  func get(with key: LocalizableKey, args: [String]) -> String
  func get(with key: LocalizableKey, args: [String]) -> LocalizedStringKey
  func get(with key: LocalizableKey) -> String
}

final class LocalizationController: LocalizationControllerType {

  private let config: any OpenID4VCIConfigType
  private let locale: Locale

  init(
    config: any OpenID4VCIConfigType,
    locale: Locale
  ) {
    self.config = config
    self.locale = locale
  }

  func get(with key: LocalizableKey, args: [String]) -> String {
    guard
      !config.translations.isEmpty,
      let translations = config.translations[locale.identifier],
      let translation = translations[key]
    else {
      return key.defaultTranslation(args: args)
    }
    return translation.format(arguments: args)
  }

  func get(with key: LocalizableKey, args: [String]) -> LocalizedStringKey {
    return self.get(with: key, args: args).toLocalizedStringKey
  }

  func get(with key: LocalizableKey) -> String {
    get(with: key, args: [])
  }
}

private struct LocalizationControllerKey: EnvironmentKey {
  static var defaultValue: LocalizationControllerType {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
      return PreviewLocalizationController()
    } else {
      return DIGraph.resolver.force(LocalizationControllerType.self)
    }
  }
}

extension EnvironmentValues {
  var localizationController: LocalizationControllerType {
    get { self[LocalizationControllerKey.self] }
    set { self[LocalizationControllerKey.self] = newValue }
  }
}

final class PreviewLocalizationController: LocalizationControllerType {
  func get(with key: LocalizableKey, args: [String]) -> String {
    key.defaultTranslation(args: args)
  }
  func get(with key: LocalizableKey, args: [String]) -> LocalizedStringKey { LocalizedStringKey("Mocked Translation") }
  func get(with key: LocalizableKey) -> String {
    key.defaultTranslation(args: [])
  }
}
