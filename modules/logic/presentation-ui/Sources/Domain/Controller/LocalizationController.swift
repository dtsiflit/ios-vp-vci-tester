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
import domain_business

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
