//
//  eudi-openid4vci-ios-app
//
import Foundation
import OpenID4VCI
import logic_business

protocol CredentialOfferInteractorType: Sendable {
  func issueCredential(offerUri: String, scope: String) async -> Result<Credential, Error>
}

final class CredentialOfferInteractor: CredentialOfferInteractorType {
  private let controller: CredentialIssuanceControllerType

  init(controller: CredentialIssuanceControllerType) {
    self.controller = controller
  }

  func issueCredential(offerUri: String, scope: String) async -> Result<Credential, Error> {
    return await controller.issueCredential(from: offerUri, scope: scope)
  }
}
