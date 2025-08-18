//
//  eudi-openid4vci-ios-app
//
@preconcurrency import Swinject

public protocol DIGraphType: Sendable {
  var assembler: Assembler { get }
  func lazyLoad(with assemblies: [Assembly])
}

public final class DIGraph: DIGraphType {

  public let assembler: Assembler

  private init() {
    self.assembler = Assembler()
  }

  public func lazyLoad(with assemblies: [Assembly]) {
    self.assembler.apply(assemblies: assemblies)
  }
}

public extension DIGraph {

  static let resolver: Resolver = shared.assembler.resolver

  static func lazyLoad(with assemblies: [Assembly]) {
    DIGraph.shared.lazyLoad(with: assemblies)
  }
}

private extension DIGraph {
  static let shared: DIGraphType = DIGraph()
}

public extension Resolver {

  func force<Service>(_ serviceType: Service.Type) -> Service {
    resolve(serviceType)!
  }

  func force<Service>(_ serviceType: Service.Type, name: String?) -> Service {
    resolve(serviceType, name: name)!
  }

  func force<Service, Arg1>(
    _ serviceType: Service.Type,
    argument: Arg1
  ) -> Service {
    resolve(serviceType, argument: argument)!
  }

  func force<Service, Arg1>(
    _ serviceType: Service.Type,
    name: String?,
    argument: Arg1
  ) -> Service {
    resolve(serviceType, name: name, argument: argument)!
  }
}
