import Foundation
import SwiftUI
import Testing

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

@Suite
@MainActor
final class SwiftUITests {
  @Test func scopedViewCoordinatorOnlyHandlesItsRoutes() {
    let home = Scoped<Root.Route, AnyView, Void, HomeCoordinator>(/Root.Route.home) {
      HomeCoordinator()
    }
    let me = Scoped<Root.Route, AnyView, Void, MeCoordinator>(/Root.Route.me) {
      MeCoordinator()
    }

    #expect(home.coordinate(to: .home(.fun)) != nil)
    #expect(home.coordinate(to: .me(.root)) == nil)
    #expect(me.coordinate(to: .me(.profile)) != nil)
    #expect(me.coordinate(to: .home(.root)) == nil)
  }

  @Test func buildViewIsEmptyWhenRouteIsNotHandled() {
    let home = Scoped<Root.Route, AnyView, Void, HomeCoordinator>(/Root.Route.home) {
      HomeCoordinator()
    }

    // `buildView` wraps the scene in an optional view; no child means the route was not handled.
    let handled = Mirror(reflecting: home.buildView(for: .home(.root), withContext: ()))
    let unhandled = Mirror(reflecting: home.buildView(for: .me(.root), withContext: ()))

    #expect(handled.displayStyle == .optional)
    #expect(handled.children.count == 1)
    #expect(unhandled.displayStyle == .optional)
    #expect(unhandled.children.isEmpty)
  }

  @Test func rootProducesViewForEveryRoute() {
    let root = Root()

    #expect(root.coordinate(to: .home(.root)) != nil)
    #expect(root.coordinate(to: .me(.profile)) != nil)
  }
}

// MARK: - RootCoordinator

extension View {
  func asAnyView() -> AnyView {
    AnyView(erasing: self)
  }
}

final class Root: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case home(HomeCoordinator.Route)
    case me(MeCoordinator.Route)
  }

  ///     typealias Scene = ???
  ///    var stack: some CoordinatorRepresentable<Route, Group<some View>, Void> {
  ///        Scoped(/Route.home) {
  ///            HomeCoordinator()
  ///        }
  ///
  ///        Scoped(/Route.me) {
  ///            MeCoordinator()
  ///        }
  ///    }
  @MainActor
  func coordinate(to route: Route, withContext context: Void) -> AnyView? {
    VStack {
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

      Combined {
        Scoped(/Route.home) {
          HomeCoordinator()
        }

        Scoped(/Route.me) {
          MeCoordinator()
        }
      }
      .coordinate(to: route)
    }
    .asAnyView()
  }
}

// MARK: - MeCoordinator

struct MeCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case root
    case profile
  }

  @MainActor
  func coordinate(to route: Route, withContext _: Void) -> AnyView? {
    VStack {
      switch route {
      case .root:
        VStack {
          Button("Me root") {}

          Color.orange
        }
        .background(Color.mint.ignoresSafeArea())
        .containerShape(Rectangle())

      case .profile:
        VStack {
          ZStack {
            Color.white
            Text("Me profile")
              .foregroundColor(.red)
              .frame(maxWidth: .infinity)
          }

          Spacer()
        }
        .containerShape(Rectangle())
      }
    }
    .asAnyView()
  }
}

// MARK: - HomeCoordinator

struct HomeCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case root
    case fun
  }

  @MainActor
  func coordinate(to route: Route, withContext _: Void) -> AnyView? {
    VStack {
      switch route {
      case .root:
        VStack {
          ZStack {
            Color.cyan
            Text("Home root")
          }

          Spacer(minLength: 0)
        }
        .containerShape(Rectangle())

      case .fun:
        VStack {
          HStack {
            Text("Home fun")
            Button("home fun") {}
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          Spacer()
        }
        .background(Color.indigo.ignoresSafeArea())
        .containerShape(Rectangle())
      }
    }
    .asAnyView()
  }
}
