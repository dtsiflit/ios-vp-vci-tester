//
//  eudi-openid4vci-ios-app
//
import Combine

protocol ViewState {}

@MainActor
class ViewModel<Router: RouterGraphType, UiState: ViewState>: ObservableObject {

  lazy var cancellables = Set<AnyCancellable>()

  @Published private(set) var viewState: UiState

  let router: Router

  init(router: Router, initialState: UiState) {
    self.router = router
    self.viewState = initialState
  }

  func setState(_ reducer: (UiState) -> UiState) {
    self.viewState = reducer(viewState)
  }
}
