//
//  eudi-openid4vci-ios-app
//
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
