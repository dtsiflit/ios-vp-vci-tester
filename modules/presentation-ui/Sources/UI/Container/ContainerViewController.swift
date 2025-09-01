//
//  eudi-openid4vci-ios-app
//
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
