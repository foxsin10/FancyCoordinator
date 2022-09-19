//
//  FancyCoodinatorTests.swift
//
//
//  Created by yzj on 2022/9/15.
//

import XCTest

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

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

            if let scene {
                XCTAssertEqual(flag, scene == .optionScene, "scene should be determined by flag, scene: \(scene), flag: \(flag)")
            } else {
                if flag {
                    XCTFail("expect get a scene with Route.option, found nil")
                }
            }
        }
    }

    func testCombinedCoordinator() {
        final class ComboCoordinator: CoordinatorRepresentable {
            enum Route {
                case showLogin
                case welcome
                case random(RandomCoordinator.Route)
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
                enum Route {
                    case random
                }
                func coordinate(to route: Route, withContext _: Void) -> Scene? {
                    switch route {
                    case .random: return .randomScene
                    }
                }
            }

            var stack: some CoordinatorRepresentable<Route, Scene, Void> {
                Combined {
                    LoginCoordinator()
                    WelcomeCoordinator()
                }
                .ifLet(/Route.random) {
                    RandomCoordinator()
                }
            }
        }

        let combo = ComboCoordinator()
        let scene = combo.coordinate(to: .showLogin)
        if let scene {
            XCTAssert(scene == .loginScene, "scene should be loginScene, found scene: \(scene))")
        }

        let randomwScene = combo.coordinate(to: .random(.random))
        if let randomwScene {
            XCTAssert(randomwScene == .randomScene, "expect to get \(ComboCoordinator.Scene.randomScene)")
        }
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
                .scoped(/Route.featureB) {
                    Feature()
                }

            FeatureA()
                .ifLet(/Route.featureA) {
                    Feature()
                }

            Scoped(/Route.featureB) {
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
