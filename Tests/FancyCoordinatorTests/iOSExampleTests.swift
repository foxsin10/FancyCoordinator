import Combine

import XCTest

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

#if os(iOS)
import SwiftUI
import UIKit

@MainActor
final class iOSCoodinatorTests: XCTestCase {}

// MARK: - AppRoute and Transition

enum AppRoute {
  case homeTimeline(HomeTimelineCoordinator.Route)
  case walletConnect(WalletCoordinator.Route)
  case welcome(WelcomeCoordinator.Route)

  var title: String {
    switch self {
    case .homeTimeline(.root): "HomeRoot"
    case .walletConnect(.selectWallet): "WalletRoot"
    default: ""
    }
  }
}

enum Transition {
  case show
  case showDetail
  case modal(animated: Bool = true, completion: () -> Void = {})
  case custom(transitionDelegate: UIViewControllerTransitioningDelegate)
}

// MARK: - CoordinatorTypeDefine

protocol Coordinator: CoordinatorRepresentable
  where Route == AppRoute, Scene == UIViewController, Context == AppCoordinateContext {}

typealias CoordinatorType = CoordinatorRepresentable<AppRoute, UIViewController, AppCoordinateContext>

// MARK: - AppCoordinateContext

final class AppCoordinateContext {
  let routeSignal = PassthroughSubject<(AppRoute, UIViewController?, Transition), Never>()

  init() {}

  func coordinate(to route: AppRoute, from scene: UIViewController?, useTransition transition: Transition) {
    routeSignal.send((route, scene, transition))
  }
}

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator {
  let coordinateContext: AppCoordinateContext

  let presentingViewController = UIViewController()

  private(set) var cancelableStorage: Set<AnyCancellable> = []

  init(
    context: AppCoordinateContext
  ) {
    coordinateContext = context

    bindRoutingSignal()
  }

  private func bindRoutingSignal() {
    coordinateContext
      .routeSignal
      .sink { [weak self] route, sender, transition in
        self?.present(route: route, from: sender, transition: transition)
      }
      .store(in: &cancelableStorage)
  }
}

extension AppCoordinator: Coordinator {
  nonisolated var stack: some CoordinatorType {
    Scoped(/Route.homeTimeline) {
      HomeTimelineCoordinator()
    }

    Scoped(/Route.walletConnect) {
      WalletCoordinator()
    }

    Scoped(/Route.welcome) {
      WelcomeCoordinator()
    }
  }
}

extension AppCoordinator {
  func present(route: Route, from sender: Scene?, transition: Transition) {
    let scene = coordinate(to: route, withContext: coordinateContext)
    guard let scene else {
      return
    }

    switch transition {
    case .show:
      presentingViewController.show(scene, sender: sender)

    case .showDetail:
      let navigationController = UINavigationController(rootViewController: scene)
      presentingViewController.showDetailViewController(navigationController, sender: sender)

    case let .modal(animated, completion):
      let modalNavigationController = UINavigationController(rootViewController: scene)
      presentingViewController.present(modalNavigationController, animated: animated, completion: completion)

    case let .custom(transitioningDelegate):
      scene.modalPresentationStyle = .custom
      scene.transitioningDelegate = transitioningDelegate
      presentingViewController.present(scene, animated: true, completion: nil)
    }
  }
}

// MARK: - ExampleController

final class ExampleController: UIViewController {
  let identifier: String
  var onNavigation: () -> Void

  init(identifier: String, onNavigation: @escaping () -> Void = {}) {
    self.identifier = identifier
    self.onNavigation = onNavigation
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let host = UIHostingController(rootView: IdentifyView(identifier: identifier, onNavigation: onNavigation))
    addChild(host)
    host.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(host.view)
    host.view.backgroundColor = .clear

    NSLayoutConstraint.activate([
      host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      host.view.topAnchor.constraint(equalTo: view.topAnchor),
      host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

struct IdentifyView: View {
  let identifier: String
  let onNavigation: () -> Void

  var body: some View {
    VStack {
      Text(identifier)
        .font(.body)
        .foregroundColor(.blue)

      Button("tap me") {
        onNavigation()
      }

      Spacer()
    }
  }
}

// MARK: - HomeTimelineCoordinator

@MainActor
struct HomeTimelineCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route: String {
    case root = "Home Root"
    case collectionDetail
    case collectibleDetail
  }

  func coordinate(to route: Route, withContext context: AppCoordinateContext) -> UIViewController? {
    switch route {
    case .root:
      let controller = ExampleController(identifier: "\(Route.root)")
      controller.onNavigation = { [context, controller] in
        context.coordinate(to: .homeTimeline(.collectionDetail), from: controller, useTransition: .show)
      }
      return controller

    case .collectionDetail:
      let controller = ExampleController(identifier: "\(Route.collectionDetail)")
      controller.onNavigation = { [context, controller] in
        context.coordinate(to: .homeTimeline(.collectibleDetail), from: controller, useTransition: .show)
      }
      return controller

    case .collectibleDetail:
      let controller = ExampleController(identifier: "\(Route.collectibleDetail)")
      return controller
    }
  }
}

// MARK: - WelcomeCoordinator

@MainActor
struct WelcomeCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case root
  }

  func coordinate(to route: Route, withContext _: AppCoordinateContext) -> UIViewController? {
    switch route {
    case .root:
      let controller = ExampleController(identifier: "\(Route.root)")
      return controller
    }
  }
}

// MARK: - WalletCoordinator

@MainActor
struct WalletCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route: String {
    case selectWallet
    case showQRCode
    case connecting
  }

  func coordinate(to route: Route, withContext context: AppCoordinateContext) -> UIViewController? {
    switch route {
    case .selectWallet:
      let controller = ExampleController(identifier: "\(Route.selectWallet)")
      controller.onNavigation = { [context, controller] in
        context.coordinate(to: .walletConnect(.showQRCode), from: controller, useTransition: .show)
      }
      return controller

    case .showQRCode:
      let controller = ExampleController(identifier: "\(Route.showQRCode)")
      controller.onNavigation = { [context, controller] in
        context.coordinate(to: .walletConnect(.connecting), from: controller, useTransition: .show)
      }
      return controller

    case .connecting:
      let controller = ExampleController(identifier: "\(Route.connecting)")
      return controller
    }
  }
}
#endif
