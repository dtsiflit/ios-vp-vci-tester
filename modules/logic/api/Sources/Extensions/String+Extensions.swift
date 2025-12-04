/*
 * Copyright (c) 2025 European Commission
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
import Foundation

public extension String {
  var nonEmpty: String? {
    isEmpty ? nil : self
  }

  func toCompatibleUrl() -> URL? {
    guard let decoded = self.removingPercentEncoding else { return nil }
    return if let url = URL(string: decoded) {
      url
    } else if let encodedString = decoded.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedString) {
      url
    } else {
      nil
    }
  }
}

public extension String? {
  var orEmpty: String {
    guard let self = self else {
      return ""
    }
    return self
  }
}
