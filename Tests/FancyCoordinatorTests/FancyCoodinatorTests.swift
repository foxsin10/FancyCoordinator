//
//  FancyCoodinatorTests.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation
import Testing

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

@Suite
@MainActor
final class FancyCoodinatorTests {
  @Test func optionalBuilder() {
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
          case .option: .optionScene
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
        #expect(flag == (scene == .optionScene), "scene should be determined by flag, scene: \(scene), flag: \(flag)")
      } else {
        if flag {
          Issue.record("expect get a scene with Route.option, found nil")
        }
      }
    }
  }

  @Test func combinedCoordinator() {
    final class ComboCoordinator: CoordinatorRepresentable {
      enum Route {
        case showLogin
        case welcome
        case random(RandomCoordinator.Route)
        case nest(NestCoordinator.Route)
      }

      enum Scene: Hashable {
        case loginScene
        case welcomScene
        case randomScene
        case nestScene
      }

      enum Context {
        case fixNumber(Int)
      }

      struct LoginCoordinator: CoordinatorRepresentable {
        func coordinate(to route: Route, withContext _: Context) -> Scene? {
          switch route {
          case .showLogin: .loginScene
          default: nil
          }
        }
      }

      struct WelcomeCoordinator: CoordinatorRepresentable {
        func coordinate(to route: Route, withContext _: Context) -> Scene? {
          switch route {
          case .welcome: .welcomScene
          default: nil
          }
        }
      }

      struct RandomCoordinator: CoordinatorRepresentable {
        enum Route {
          case random
        }

        func coordinate(to route: Route, withContext _: Context) -> Scene? {
          switch route {
          case .random: .randomScene
          }
        }
      }

      struct NestCoordinator: CoordinatorRepresentable {
        enum Route {
          case number(Int)
        }

        func coordinate(to route: Route, withContext _: Int) -> Scene? {
          switch route {
          case .number:
            .nestScene
          }
        }
      }

      var stack: some CoordinatorRepresentable<Route, Scene, Context> {
        Combined {
          LoginCoordinator()
          WelcomeCoordinator()

          Scoped(/Route.nest, context: /Context.fixNumber) {
            NestCoordinator()
          }
        }
        .ifLet(/Route.random) {
          RandomCoordinator()
        }
      }
    }

    let combo = ComboCoordinator()
    let scene = combo.coordinate(to: .showLogin, withContext: .fixNumber(1))
    if let scene {
      #expect(scene == .loginScene, "scene should be loginScene, found scene: \(scene))")
    }

    let randomwScene = combo.coordinate(to: .random(.random), withContext: .fixNumber(2))
    if let randomwScene {
      #expect(randomwScene == .randomScene, "expect to get \(ComboCoordinator.Scene.randomScene)")
    }

    let nestScene = combo.coordinate(to: .nest(.number(2)), withContext: .fixNumber(2))

    if let nestScene {
      #expect(nestScene == .nestScene, "expect to get \(ComboCoordinator.Scene.nestScene)")
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
        case .featureA: .action
        default: nil
        }
      }
    }

    struct FeatureB: CoordinatorRepresentable {
      func coordinate(to route: Route, withContext _: Context) -> Scene? {
        switch route {
        case .featureB: .action
        default: nil
        }
      }
    }
  }
}
