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

public protocol AttestationRepositoryType: Sendable {
  func getChallenge(payload: Data) async throws -> ChallengeResponse
  func issueWalletInstanceAttestationJwk(payload: Data) async throws -> WalletInstanceAttestation
  func issueWalletInstanceAttestationIos(payload: Data) async throws -> WalletUnitAttestation
}

public actor AttestationRepository: AttestationRepositoryType {
  
  private let networkManager: NetworkManager
  private let host: String
  
  init(
    networkManager: NetworkManager,
    host: String = "https://dev.wallet-provider.eudiw.dev"
  ) {
    self.networkManager = networkManager
    self.host = host
  }
  
  public func getChallenge(payload: Data) async throws -> ChallengeResponse {
    try await networkManager.execute(
      with: GetChallengeRequest(request: payload),
      parameters: nil
    )
  }
  
  public func issueWalletInstanceAttestationJwk(payload: Data) async throws -> WalletInstanceAttestation {
    try await networkManager.execute(
      with: IssueAttestationJWKRequest(request: payload, host: host),
      parameters: nil
    )
  }
  
  public func issueWalletInstanceAttestationIos(payload: Data) async throws -> WalletUnitAttestation {
    try await networkManager.execute(
      with: IssueAttestationIOSRequest(request: payload, host: host),
      parameters: nil
    )
  }
}
