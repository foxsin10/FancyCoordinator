import UIKit

import FancyCoordinator

struct WelcomeCoordinator: CoordinatorRepresentable {
    enum Route {
        case root
    }

    func coordinate(to route: Route, withContext _: AppCoordinateContext) -> UIViewController? {
        switch route {
        case .root:
            let controller = ExcampleController(identifier: "\(Route.root)")
            return controller
        }
    }
}
