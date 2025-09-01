//
//  eudi-openid4vci-ios-app
//

public extension DIGraph {
  @MainActor static func assembleDependenciesGraph() {
    DIGraph.lazyLoad(
      with: [
        DomainBusinessAssembly(),
        ServiceVCIAssembly(),
        ServiceVPAssembly(),
        PresentationUIAssembly(),
        AssemblyModule()
      ]
    )
  }
}
