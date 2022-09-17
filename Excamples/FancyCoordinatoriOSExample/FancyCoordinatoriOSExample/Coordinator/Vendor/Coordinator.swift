import UIKit

import FancyCoordinator

protocol Coordinator: CoordinatorRepresentable
    where Route == AppRoute, Scene == UIViewController, Context == AppCoordinateContext {}

typealias CoordinatorType = CoordinatorRepresentable<AppRoute, UIViewController, AppCoordinateContext>
