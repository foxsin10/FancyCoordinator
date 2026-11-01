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

    #expect(OptionCoordinator(flag: true).coordinate(to: .option) == .optionScene)
    #expect(OptionCoordinator(flag: false).coordinate(to: .option) == nil)
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
    #expect(combo.coordinate(to: .showLogin, withContext: .fixNumber(1)) == .loginScene)
    #expect(combo.coordinate(to: .welcome, withContext: .fixNumber(1)) == .welcomScene)
    #expect(combo.coordinate(to: .random(.random), withContext: .fixNumber(2)) == .randomScene)
    #expect(combo.coordinate(to: .nest(.number(2)), withContext: .fixNumber(2)) == .nestScene)
  }

  @Test func ifLetRoutesToChildOrFallsBackToParent() {
    enum Route {
      case parent
      case child(Int)
    }

    struct ParentCoordinator: CoordinatorRepresentable {
      func coordinate(to route: Route, withContext _: Void) -> String? {
        if case .parent = route { return "parent" }
        return nil
      }
    }

    struct ChildCoordinator: CoordinatorRepresentable {
      func coordinate(to id: Int, withContext _: Void) -> String? {
        "child \(id)"
      }
    }

    let coordinator = ParentCoordinator().ifLet({ route -> Int? in
      if case let .child(id) = route { return id }
      return nil
    }) {
      ChildCoordinator()
    }

    #expect(coordinator.coordinate(to: .parent) == "parent")
    #expect(coordinator.coordinate(to: .child(7)) == "child 7")
  }

  @Test func scopedReturnsNilWhenRouteOrContextDoesNotMatch() {
    enum Route {
      case user(Int)
      case settings
    }

    enum Context {
      case loggedIn(String)
      case guest
    }

    struct ProfileCoordinator: CoordinatorRepresentable {
      func coordinate(to id: Int, withContext name: String) -> String? {
        "\(name) #\(id)"
      }
    }

    let coordinator = Scoped<Route, String, Context, ProfileCoordinator>(/Route.user, context: /Context.loggedIn) {
      ProfileCoordinator()
    }

    #expect(coordinator.coordinate(to: .user(7), withContext: .loggedIn("amy")) == "amy #7")
    #expect(coordinator.coordinate(to: .user(7), withContext: .guest) == nil)
    #expect(coordinator.coordinate(to: .settings, withContext: .loggedIn("amy")) == nil)
  }

  @Test func arrayBuilderReturnsFirstMatchingCoordinator() {
    struct BelowCoordinator: CoordinatorRepresentable {
      let limit: Int

      func coordinate(to value: Int, withContext _: Void) -> String? {
        value < limit ? "below \(limit)" : nil
      }
    }

    let coordinator = Combined<Int, String, Void, _> {
      for limit in [10, 20, 30] {
        BelowCoordinator(limit: limit)
      }
    }

    #expect(coordinator.coordinate(to: 5) == "below 10")
    #expect(coordinator.coordinate(to: 15) == "below 20")
    #expect(coordinator.coordinate(to: 35) == nil)
  }

  @Test func scopedMethodSendsEachRouteToExactlyOneSide() {
    enum Route {
      case home
      case user(Int)
    }

    enum Context {
      case loggedIn(String)
      case guest
    }

    struct ParentCoordinator: CoordinatorRepresentable {
      func coordinate(to route: Route, withContext _: Context) -> String? {
        switch route {
        case .home: "home"
        case .user: "parent user"
        }
      }
    }

    struct UserCoordinator: CoordinatorRepresentable {
      func coordinate(to id: Int, withContext _: Context) -> String? {
        "user \(id)"
      }
    }

    struct ProfileCoordinator: CoordinatorRepresentable {
      func coordinate(to id: Int, withContext name: String) -> String? {
        "\(name) #\(id)"
      }
    }

    let context = Context.loggedIn("amy")

    // Child-case routes never reach the parent, even though the parent handles `.user`.
    let casePathScoped = ParentCoordinator().scoped(/Route.user) {
      UserCoordinator()
    }
    #expect(casePathScoped.coordinate(to: .home, withContext: context) == "home")
    #expect(casePathScoped.coordinate(to: .user(7), withContext: context) == "user 7")

    let contextScoped = ParentCoordinator().scoped(/Route.user, context: /Context.loggedIn) {
      ProfileCoordinator()
    }
    #expect(contextScoped.coordinate(to: .home, withContext: context) == "home")
    #expect(contextScoped.coordinate(to: .user(7), withContext: context) == "amy #7")
    #expect(contextScoped.coordinate(to: .user(7), withContext: .guest) == nil)

    let closureScoped = ParentCoordinator().scoped(
      toChildRoute: { route -> Int? in
        if case let .user(id) = route { return id }
        return nil
      },
      toChildContext: { context -> String? in
        if case let .loggedIn(name) = context { return name }
        return nil
      }
    ) {
      ProfileCoordinator()
    }
    #expect(closureScoped.coordinate(to: .home, withContext: context) == "home")
    #expect(closureScoped.coordinate(to: .user(7), withContext: context) == "amy #7")
    #expect(closureScoped.coordinate(to: .user(7), withContext: .guest) == nil)
  }

  @Test func builderSupportsIfElseAvailabilityAndEmptyBlocks() {
    struct FixedCoordinator: CoordinatorRepresentable {
      let scene: String

      func coordinate(to _: Int, withContext _: Void) -> String? {
        scene
      }
    }

    struct EitherCoordinator: CoordinatorRepresentable {
      let flag: Bool

      var stack: some CoordinatorRepresentable<Int, String, Void> {
        if flag {
          FixedCoordinator(scene: "first")
        } else {
          FixedCoordinator(scene: "second")
        }
      }
    }

    struct AvailabilityCoordinator: CoordinatorRepresentable {
      var stack: some CoordinatorRepresentable<Int, String, Void> {
        if #available(iOS 15, macOS 12, watchOS 8, *) {
          FixedCoordinator(scene: "available")
        }
      }
    }

    #expect(EitherCoordinator(flag: true).coordinate(to: 1) == "first")
    #expect(EitherCoordinator(flag: false).coordinate(to: 1) == "second")
    #expect(AvailabilityCoordinator().coordinate(to: 1) == "available")
    #expect(Combined<Int, String, Void, _> {}.coordinate(to: 1) == nil)
  }

  @Test func firstMatchingCoordinatorWins() {
    struct FixedCoordinator: CoordinatorRepresentable {
      let scene: String?

      func coordinate(to _: Int, withContext _: Void) -> String? {
        scene
      }
    }

    let combined = Combined<Int, String, Void, _> {
      FixedCoordinator(scene: nil)
      FixedCoordinator(scene: "second")
      FixedCoordinator(scene: "third")
    }
    #expect(combined.coordinate(to: 1) == "second")

    typealias Builder = CoordinatorBuilder<Int, String, Void>

    let sequenced = Builder.Sequenced(c0: FixedCoordinator(scene: "a"), c1: FixedCoordinator(scene: "b"))
    #expect(sequenced.coordinate(to: 1) == "a")

    let many = Builder.SequensedMany(coordinators: [FixedCoordinator(scene: nil), FixedCoordinator(scene: "b")])
    #expect(many.coordinate(to: 1) == "b")
    #expect(Builder.SequensedMany<FixedCoordinator>(coordinators: []).coordinate(to: 1) == nil)

    #expect(Builder.OptionalCoordinator(wrapped: FixedCoordinator(scene: "a")).coordinate(to: 1) == "a")
    #expect(Builder.OptionalCoordinator<FixedCoordinator>(wrapped: nil).coordinate(to: 1) == nil)
  }

  @Test func scopedFilterTransformsRouteForSelf() {
    struct EchoCoordinator: CoordinatorRepresentable {
      func coordinate(to route: Int, withContext _: Void) -> String? {
        "route \(route)"
      }
    }

    let coordinator = EchoCoordinator().scoped { $0 > 0 ? $0 * 10 : nil }

    #expect(coordinator.coordinate(to: 3) == "route 30")
    #expect(coordinator.coordinate(to: -1) == nil)
  }

  @Test func ifLetWithCasePathRoutesToChildOrFallsBackToParent() {
    enum Route {
      case parent
      case child(Int)
    }

    struct ParentCoordinator: CoordinatorRepresentable {
      func coordinate(to route: Route, withContext _: Void) -> String? {
        switch route {
        case .parent: "parent"
        case .child: "parent child"
        }
      }
    }

    struct ChildCoordinator: CoordinatorRepresentable {
      func coordinate(to id: Int, withContext _: Void) -> String? {
        "child \(id)"
      }
    }

    // An explicit `CasePath` value; `/Route.child` would pick the closure-based `ifLet`.
    let casePath = CasePath<Route, Int>(Route.child)

    let viaMethod = ParentCoordinator().ifLet(casePath) {
      ChildCoordinator()
    }
    #expect(viaMethod.coordinate(to: .parent) == "parent")
    #expect(viaMethod.coordinate(to: .child(7)) == "child 7")

    let viaInit = IfLet(
      parent: ParentCoordinator(),
      child: ChildCoordinator(),
      toChildCasePath: casePath,
      toChildContext: { $0 },
      file: #file,
      fileID: #fileID,
      line: #line
    )
    #expect(viaInit.coordinate(to: .parent) == "parent")
    #expect(viaInit.coordinate(to: .child(7)) == "child 7")
  }

  @Test func emptyNeverProducesScene() {
    #expect(Empty<Int, String, Void>().coordinate(to: 1) == nil)
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
