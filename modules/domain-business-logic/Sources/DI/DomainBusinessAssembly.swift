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
import Swinject

public final class DomainBusinessAssembly: Assembly {

  public init() {}

  public func assemble(container: Container) {
    
    container.register(WalletProviderClient.self) { _ in
      WalletProviderClient(baseURL: URL(
        string: "https://dev.wallet-provider.eudiw.dev"
      )!)
    }
    .inObjectScope(.container)

    container.register(AppAttestClient.self) { r in
      AppAttestClient(
        walletClient: r.force(WalletProviderClient.self)
      )
    }
    .inObjectScope(ObjectScope.container)
    
    container.register(KeyProvider.self) { _ in
      KeyProviderImpl()
    }
    .inObjectScope(.container)
  }
}
