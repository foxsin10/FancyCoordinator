import Combine
import UIKit

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

@MainActor
final class AppCoordinator {
    weak var sceneDelegate: SceneDelegate?
    let coordinateContext: AppCoordinateContext

    private(set) var cancelableStorage: Set<AnyCancellable> = []

    init(
        sceneDelegate: SceneDelegate?,
        context: AppCoordinateContext
    ) {
        self.sceneDelegate = sceneDelegate
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

extension AppCoordinator {
    func start() {

        let tabBarController = UITabBarController.init()

        let controllers = [Route.homeTimeline(.root), Route.walletConnect(.selectWallet)]
            .compactMap {
                let controller = coordinate(to: $0, withContext: coordinateContext)
                if let controller {
                    let navigationController =  UINavigationController(rootViewController: controller)
                    navigationController.title = $0.title

                    return navigationController
                }

                return nil
            }

        tabBarController.setViewControllers(controllers, animated: false)
        sceneDelegate?.window?.rootViewController = tabBarController

        if Bool.random() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.present(route: .welcome(.root), from: nil, transition: .modal())
            }
        }
    }
}

extension AppCoordinator: Coordinator {
    var stack: some CoordinatorType {
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
        let scene = coordinate(to: route, withContext: self.coordinateContext)
        let sceneDelegateAdapter = self.sceneDelegate

        guard let scene = scene,
              let presentingViewController = sender ?? sceneDelegateAdapter?.window?.rootViewController else {
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
