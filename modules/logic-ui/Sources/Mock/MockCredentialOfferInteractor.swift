//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI
import SwiftyJSON

public final class MockCredentialOfferInteractor: CredentialOfferInteractorType {

  public init() {}

  public func issueCredential(offerUri: String, scope: String) async -> Result<Credential, Error> {
    try? await Task.sleep(nanoseconds: 100_000_000)

    let jsonCredential: JSON = [
      "id": "mock-credential-\(UUID().uuidString)",
      "type": ["MockCredential"],
      "issuanceDate": ISO8601DateFormatter().string(from: Date()),
      "credentialSubject": [
        "name": "Demo User",
        "scope": scope
      ]
    ]

    let mockCredential = Credential.json(jsonCredential)
    return .success(mockCredential)
  }
}
