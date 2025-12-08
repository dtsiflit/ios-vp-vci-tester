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
import Swinject
import Foundation
import service_vci
import service_vp
import domain_business
import api

public final class PresentationUIAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {

    container.register(CredentialOfferInteractorType.self) { r in
      return CredentialOfferInteractor(
        keyProvider: KeyProviderImpl(),
        controller: r.force(CredentialIssuanceControllerType.self),
        attestationClient: r.force(AttestationClientType.self)
      )
    }
    .inObjectScope(.container)

    container.register(CredentialPresentationInteractorType.self) { r in
      CredentialPresentationInteractor(
        controller: r.force(CredentialPresentationControllerType.self)
      )
    }
    .inObjectScope(.container)

    container.register(LocalizationControllerType.self) { _ in
      return LocalizationController(
        config: OpenID4VCIConfig(),
        locale: Locale.current
      )
    }
    .inObjectScope(.container)
  }
}
