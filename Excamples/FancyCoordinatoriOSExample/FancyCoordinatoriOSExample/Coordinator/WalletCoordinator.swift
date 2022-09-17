import UIKit

import FancyCoordinator

struct WalletCoordinator: CoordinatorRepresentable {
    enum Route: String {
        case selectWallet
        case showQRCode
        case connecting
    }

    func coordinate(to route: Route, withContext context: AppCoordinateContext) -> UIViewController? {
        switch route {
        case .selectWallet:
            let controller = ExcampleController(identifier: "\(Route.selectWallet)")
            controller.onNavigation = { [context, controller] in
                context.coordinate(to: .walletConnect(.showQRCode), from: controller, useTransition: .show)
            }
            return controller

        case .showQRCode:
            let controller = ExcampleController(identifier: "\(Route.showQRCode)")
            controller.onNavigation = { [context, controller] in
                context.coordinate(to: .walletConnect(.connecting), from: controller, useTransition: .show)
            }
            return controller

        case .connecting:
            let controller = ExcampleController(identifier: "\(Route.connecting)")
            return controller
        }
    }
}
