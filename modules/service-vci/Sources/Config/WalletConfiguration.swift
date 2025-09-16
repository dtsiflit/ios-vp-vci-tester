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

public struct WalletConfiguration {

  public static let scheme = "eudi-openid4ci"

  public static let clientConfig: OpenId4VCIConfig = .init(
    client: .public(id: "wallet-dev"),
    authFlowRedirectionURI: URL(string: "eudi-openid4ci://authorize")!,
    authorizeIssuanceConfig: .favorScopes
  )
}
