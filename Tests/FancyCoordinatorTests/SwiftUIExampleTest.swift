import Foundation
import SwiftUI
import Testing

import CasePaths

import FancyCoordinator
import FancyCoordinatorWithCasePath

@Suite
@MainActor
final class SwiftUITests {}

// MARK: - RootCoordinator

final class Root: CoordinatorRepresentable {
  enum Route {
    case home(HomeCoordinator.Route)
    case me(MeCoordinator.Route)
  }

//     typealias Scene = ???
//    var stack: some CoordinatorRepresentable<Route, Group<some View>, Void> {
//        Scoped(/Route.home) {
//            HomeCoordinator()
//        }
//
//        Scoped(/Route.me) {
//            MeCoordinator()
//        }
//    }

  func coordinate(to route: Route, withContext context: Void) -> Group<some View>? {
    Group {
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

//             Combined {
//                 Scoped(/Route.home) {
//                     HomeCoordinator()
//                 }
//
//                 Scoped(/Route.me) {
//                     MeCoordinator()
//                 }
//             }
//             .coordinate(to: route)
    }
  }
}

// MARK: - MeCoordinator

struct MeCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case root
    case profile
  }

  @MainActor
  func coordinate(to route: Route, withContext _: Void) -> Group<some View>? {
    Group {
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
  }
}

// MARK: - HomeCoordinator

struct HomeCoordinator: @preconcurrency CoordinatorRepresentable {
  enum Route {
    case root
    case fun
  }

  @MainActor
  func coordinate(to route: Route, withContext _: Void) -> Group<some View>? {
    Group {
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
  }
}
