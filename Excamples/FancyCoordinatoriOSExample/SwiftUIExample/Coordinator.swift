//
//  Coordinator.swift
//  SwiftUIExample
//
//  Created by yzj on 2022/9/17.
//

import SwiftUI

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

final class Root: CoordinatorRepresentable {
    enum Route {
        case home(HomeCoordinator.Route)
        case me(MeCoordinator.Route)
    }

//     typealias Scene = ???
//    var stack: some CoordinatorRepresentable<Route, ViewBuilder._ConditionalContent<some View>, Void> {
//        Scoped(/Route.home) {
//            HomeCoordinator()
//        }
//
//        Scoped(/Route.me) {
//            MeCoordinator()
//        }
//    }

    func coordinate(to route: Route, withContext context: Void) -> Group<some View>? {
        @ViewBuilder
        func buildView(for route: Route) -> some View {
            switch route {
            case .home:
                Scoped(/Route.home) {
                    HomeCoordinator()
                }
                .coordinate(to: route, withContext: context)

            case .me:
                Scoped(/Route.me) {
                    MeCoordinator()
                }
                .coordinate(to: route, withContext: context)
            }
        }

        let view = buildView(for: route)

        return Group {
            view
        }
    }
}

struct MeCoordinator: CoordinatorRepresentable {
    enum Route {
        case root
        case profile
    }

    func coordinate(to route: Route, withContext context: Void) -> Group<some View>? {
        @ViewBuilder
        func buildView(for route: Route) -> some View {
            switch route {
            case .root:
                VStack {
                    ZStack {
                        Color.blue
                    }

                    Spacer()
                }

            case .profile:
                VStack {
                    ZStack {
                        Text("131")
                    }

                    Spacer()
                }
            }
        }

        let view = buildView(for: route)

        return Group {
            view
        }
    }
}

struct HomeCoordinator {
    enum Route {
        case root
        case fun
    }
}

extension HomeCoordinator: CoordinatorRepresentable {
    func coordinate(to route: Route, withContext _: Void) -> Group<some View>? {
        @ViewBuilder
        func buildView(for route: Route) -> some View {
            switch route {
            case .root:
                VStack {
                    ZStack {
                        Color.cyan
                    }

                    Spacer()
                }

            case .fun:
                VStack {
                    ZStack {
                        Text("1314")
                    }

                    Spacer()
                }
            }
        }

        let view = buildView(for: route)

        return Group {
            view
        }
    }
}
