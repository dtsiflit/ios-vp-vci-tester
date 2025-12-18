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
import SwiftUI
import presentation_ui

public struct ContainerView<Router: RouterGraph, Content: View>: View {

  @ObservedObject var router: Router
  
  public let content: Content

  public init(router: Router, @ViewBuilder content: @escaping (Router) -> Content) {
    self.router = router
    self.content = content(router)
  }

  public var body: some View {
    NavigationStack(path: $router.path) {
      content
        .navigationDestination(for: Route.self) { route in
          router.view(for: route)
        }
    }
  }
}
