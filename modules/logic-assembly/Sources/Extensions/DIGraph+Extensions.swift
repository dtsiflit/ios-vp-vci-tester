//
//  eudi-openid4vci-ios-app
//

public extension DIGraph {
  @MainActor static func assembleDependenciesGraph() {
    DIGraph.lazyLoad(
      with: [
        LogicBusinessAssembly(),
        LogicUIAssembly(),
        LogicAssemblyModule()
      ]
    )
  }
}
