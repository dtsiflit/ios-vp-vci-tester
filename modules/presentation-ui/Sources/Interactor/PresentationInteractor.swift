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
import service_vp

protocol PresentationInteractorType: Sendable {
  func loadAndPresentDocument(url: String) async throws
}

final class PresentationInteractor: PresentationInteractorType {

  private let controller: PresentationControllerType

  init(
    controller: PresentationControllerType
  ) {
    self.controller = controller
  }

  func loadAndPresentDocument(url: String) async {
    await controller.loadAndPresentDocument(url: url)
  }
}
