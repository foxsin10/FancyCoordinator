import UIKit

import FancyCoordinator

struct HomeTimelineCoordinator: CoordinatorRepresentable {
    enum Route: String {
        case root = "Home Root"
        case collectionDetail
        case collectibleDetail
    }

    func coordinate(to route: Route, withContext context: AppCoordinateContext) -> UIViewController? {
        switch route {
        case .root:
            let controller = ExcampleController(identifier: "\(Route.root)")
            controller.onNavigation = { [context, controller] in
                context.coordinate(to: .homeTimeline(.collectionDetail), from: controller, useTransition: .show)
            }
            return controller

        case .collectionDetail:
            let controller = ExcampleController(identifier: "\(Route.collectionDetail)")
            controller.onNavigation = { [context, controller] in
                context.coordinate(to: .homeTimeline(.collectibleDetail), from: controller, useTransition: .show)
            }
            return controller

        case .collectibleDetail:
            let controller = ExcampleController(identifier: "\(Route.collectibleDetail)")
            return controller
        }
    }
}
