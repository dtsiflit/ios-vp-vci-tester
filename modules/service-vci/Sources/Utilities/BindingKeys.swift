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
import Foundation
import OpenID4VCI
import JOSESwift

public enum BindingKeys {
  public static let bindingKey: BindingKey = {
    let privateKey = try! KeyController.generateECDHPrivateKey()
    let publicKey = try! KeyController.generateECDHPublicKey(from: privateKey)

    let alg = JWSAlgorithm(.ES256)
    let publicKeyJWK = try! ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ]
    )

    return .jwk(
      algorithm: alg,
      jwk: publicKeyJWK,
      privateKey: .secKey(privateKey)
    )
  }()
}

extension BindingKey {
  var privateKey: SecKey? {
    switch self {
    case .jwk(_, _, let privateKeyProxy, _),
        .keyAttestation(_, _, _, let privateKeyProxy, _):
      if case let .secKey(secKey) = privateKeyProxy {
        return secKey
      } else {
        return nil
      }
    default:
      return nil
    }
  }

  public var privateKeyOrGenerate: SecKey {
    if let key = self.privateKey {
      return key
    }
    return try! KeyController.generateECDHPrivateKey()
  }
}
