//
//  FancyCoodinatorTests.swift
//
//
//  Created by yzj on 2022/9/15.
//

import XCTest
@testable import FancyCoordinator

@MainActor
final class FancyCoodinatorTests: XCTestCase {
    func testOptionalBuilder() {
        final class OptionCoordinator: CoordinatorRepresentable {
            typealias Context = Void

            enum Route {
                case option
            }

            enum Scene: Hashable {
                case optionScene
            }

            struct ChildCoordinator: CoordinatorRepresentable {
                func coordinate(to route: Route, withContext _: Void) -> Scene? {
                    switch route {
                    case .option: return .optionScene
                    }
                }
            }

            let flag: Bool
            init(flag: Bool) {
                self.flag = flag
            }

            var stack: some CoordinatorRepresentable<Route, Scene, Void> {
                if flag {
                    ChildCoordinator()
                }
            }
        }

        let flags = [Bool.random(), Bool.random()]

        for flag in flags {
            let coordinator = OptionCoordinator(flag: flag)
            let scene = coordinator.coordinate(to: .option)

            XCTAssertEqual(flag, scene == .optionScene, "scene should be determined by flag, scene: \(scene.debugHash), flag: \(flag)")
        }
    }

    func testCombinedCoordinator() {
        final class ComboCoordinator: CoordinatorRepresentable {
            enum Route {
                case showLogin
                case welcome
                case random
            }

            enum Scene: Hashable {
                case loginScene
                case welcomScene
                case randomScene
            }

            typealias Context = Void

            struct LoginCoordinator: CoordinatorRepresentable {
                func coordinate(to route: Route, withContext _: Void) -> Scene? {
                    switch route {
                    case .showLogin: return .loginScene
                    default: return nil
                    }
                }
            }

            struct WelcomeCoordinator: CoordinatorRepresentable {
                func coordinate(to route: Route, withContext _: Void) -> Scene? {
                    switch route {
                    case .welcome: return .welcomScene
                    default: return nil
                    }
                }
            }

            struct RandomCoordinator: CoordinatorRepresentable {
                func coordinate(to route: Route, withContext _: Void) -> Scene? {
                    switch route {
                    case .random: return .randomScene
                    default: return nil
                    }
                }
            }

            var stack: some CoordinatorRepresentable<Route, Scene, Void> {
                Combined {
                    LoginCoordinator()
                    WelcomeCoordinator()
                }
                .ifLet { route in
                    switch route {
                    case .showLogin: return .random
                    default: return nil
                    }
                } then: { RandomCoordinator() }
            }
        }

        let scene = ComboCoordinator().coordinate(to: .showLogin)
        XCTAssert(scene == .randomScene, "scene should be randomScene, found scene: \(scene.debugHash)")
    }
}

extension Optional where Wrapped: Hashable {
    fileprivate var debugHash: Int {
        self?.hashValue ?? -10
    }
}


private struct RootCoordinator: CoordinatorRepresentable {
    enum Scene {
        case featureA(Feature.Route)
        case featureB(Feature.Route)
        case action
    }

    enum Route {
        case filter
    }

    typealias Context = Void

    var stack: some CoordinatorRepresentable<Route, Scene, Void> {
        Combined {
            Empty()
        }
    }

    @CoordinatorBuilder<Route, Scene, Void>
    var testFlowControl: some CoordinatorRepresentable<Route, Scene, Void> {
        if true {
            Self()
        }

        if Bool.random() {
            Self()
        } else {
            Empty()
        }

        for _ in 1 ... 10 {
            Self()
        }

        if #available(*) {
            Self()
        }
    }

    struct Feature: CoordinatorRepresentable {
        struct Route: Identifiable {
            let id: Int
        }

        typealias Context = Void

        func coordinate(to _: Route, withContext _: Context) -> Scene? {
            nil
        }
    }

    struct Features: CoordinatorRepresentable {
        enum Route {
            case featureA(Feature.Route)
            case featureB(Feature.Route)
        }

        typealias Context = Void
        typealias Scene = RootCoordinator.Scene

        var stack: some CoordinatorRepresentable<Route, Scene, Void> {
            FeatureA()
            FeatureB()
                .scoped { route in
                    switch route {
                    case let .featureB(r):
                        if r.id < 10 {
                            return r
                        } else {
                            return nil
                        }
                    default: return nil
                    }
                } then: {
                    Feature()
                }

            FeatureA()
                .ifLet { route in
                    switch route {
                    case let .featureA(route): return route
                    default: return nil
                    }
                } then: {
                    Feature()
                }

            Scoped(
                { route in
                    switch route {
                    case let .featureB(f):
                        return f
                    default: return nil
                    }
                }
            ) {
                Feature()
            }
        }

        struct FeatureA: CoordinatorRepresentable {
            func coordinate(to route: Route, withContext _: Context) -> Scene? {
                switch route {
                case .featureA: return .action
                default: return nil
                }
            }
        }

        struct FeatureB: CoordinatorRepresentable {
            func coordinate(to route: Route, withContext _: Context) -> Scene? {
                switch route {
                case .featureB: return .action
                default: return nil
                }
            }
        }
    }
}
