import SwiftUI
import XCTest

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

private final class RootCoordinator: CoordinatorRepresentable {
    enum Route {
        case home(HomeCoordinator.Route)
        case me
    }

    typealias Context = Void
    typealias Scene = View

    var stack: some CoordinatorRepresentable<Route,  View, Void> {
        Scoped(/Route.home) {
            HomeCoordinator()
        }
    }

    struct HomeCoordinator: CoordinatorRepresentable {
        enum Route {
            case root
        }

        @ViewBuilder
        func coordinate(to route: Route, withContext context: Context) -> (any Scene)? {
            switch route {
            case .root:
                VStack {
                    Text("3131")

                    Color.blue
                        .frame(width: 200, height: 40)
                        .cornerRadius(12)

                    Spacer()
                }
            }
        }
    }
}

final class SwiftUITests: XCTestCase {
    func testSwiftUITestCompile() {
        
    }
}
