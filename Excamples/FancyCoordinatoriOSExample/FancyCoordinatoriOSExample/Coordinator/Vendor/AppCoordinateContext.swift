import Combine
import UIKit

final class AppCoordinateContext {
    let routeSignal = PassthroughSubject<(AppRoute, UIViewController?, Transition), Never>()

    init() {}

    func coordinate(to route: AppRoute, from scene: UIViewController?, useTransition transition: Transition) {
        routeSignal.send((route, scene, transition))
    }
}
