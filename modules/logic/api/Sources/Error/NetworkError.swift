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

enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingFailed(Error)
  case httpError(statusCode: Int, data: Data?)
  case unauthorized
  case serverError
  case unknown(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .noData:
      return "No data received"
    case .decodingFailed(let error):
      return "Failed to decode: \(error.localizedDescription)"
    case .httpError(let code, _):
      return "HTTP Error: \(code)"
    case .unauthorized:
      return "Unauthorized access"
    case .serverError:
      return "Server error occurred"
    case .unknown(let error):
      return "Unknown error: \(error.localizedDescription)"
    }
  }
}
