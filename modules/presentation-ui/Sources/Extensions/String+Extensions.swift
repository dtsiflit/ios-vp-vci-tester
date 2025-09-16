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

extension String {
  var toLocalizedStringKey: LocalizedStringKey {
    LocalizedStringKey(self)
  }

  var base64UrlDecodedData: Data? {
    var base64 = self
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let remainder = base64.count % 4
    if remainder > 0 {
      base64 += String(repeating: "=", count: 4 - remainder)
    }

    return Data(base64Encoded: base64)
  }

  var base64UrlDecodedString: String? {
    guard let data = self.base64UrlDecodedData else { return nil }
    return String(data: data, encoding: .utf8)
  }

  func format(arguments: [CVarArg]? = nil) -> String {
    guard let arguments, !arguments.isEmpty else {
      return self
    }
    return String(format: self, locale: nil, arguments: arguments)
  }
}
