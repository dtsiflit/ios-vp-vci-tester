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

enum X963ExportError: Error, LocalizedError {
  case notECKey
  case cfError(Error)
  case unexpectedFormat
  
  var errorDescription: String? {
    switch self {
    case .notECKey: return "Key is not an EC P-256 key."
    case .cfError(let e): return "Security framework error: \(e.localizedDescription)"
    case .unexpectedFormat: return "Exported key is not in uncompressed X9.63 format."
    }
  }
}
