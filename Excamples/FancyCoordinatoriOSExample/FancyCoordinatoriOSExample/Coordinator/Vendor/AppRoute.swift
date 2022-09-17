import UIKit

enum AppRoute {
    case homeTimeline(HomeTimelineCoordinator.Route)
    case walletConnect(WalletCoordinator.Route)
    case welcome(WelcomeCoordinator.Route)

    var title: String {
        switch self {
        case .homeTimeline(.root): return "HomeRoot"
        case .walletConnect(.selectWallet): return "WalletRoot"
        default: return ""
        }
    }
}

enum Transition {
    case show
    case showDetail
    case modal(animated: Bool = true, completion: () -> Void = {})
    case custom(transitionDelegate: UIViewControllerTransitioningDelegate)
}
