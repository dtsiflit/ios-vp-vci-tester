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
import UIKit
import SwiftUI

class ContainerViewController<Content: View>: UIViewController {

  private let rootView: Content

  init(rootView: Content) {
    self.rootView = rootView
    super.init(nibName: nil, bundle: nil)
    self.modalPresentationStyle = .fullScreen
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let hostingController = UIHostingController(rootView: rootView)
    addChild(hostingController)
    pinToEdges(hostingController.view)
  }
}

private extension ContainerViewController {

  func pinToEdges(_ subview: UIView) {

    subview.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(subview)

    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: view.topAnchor),
      subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
