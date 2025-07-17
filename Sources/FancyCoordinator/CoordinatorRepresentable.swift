//
//  CoordinatorRepresentable.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public protocol CoordinatorRepresentable<Route, Scene, Context> {
  associatedtype Route
  associatedtype Scene
  associatedtype Context

  associatedtype Stack

  func coordinate(to route: Route, withContext context: Context) -> Scene?

  @CoordinatorBuilder<Route, Scene, Context>
  var stack: Self.Stack { get }
}

public extension CoordinatorRepresentable where Stack == Never {
  @_transparent
  var stack: Stack {
    fatalError("\(self) with body refers to never should not call this property directly")
  }
}

public extension CoordinatorRepresentable where Stack: CoordinatorRepresentable, Stack.Scene == Scene, Stack.Route == Route, Stack.Context == Context {
  func coordinate(to route: Route, withContext context: Context) -> Scene? {
    stack.coordinate(to: route, withContext: context)
  }
}

public extension CoordinatorRepresentable where Context == Void {
  func coordinate(to route: Route) -> Scene? {
    coordinate(to: route, withContext: ())
  }
}

#if canImport(SwiftUI)
import SwiftUI

public extension CoordinatorRepresentable where Scene: View {
  @ViewBuilder
  @MainActor
  func buildView(for route: Route, withContext context: Context) -> some View {
    if let view = coordinate(to: route, withContext: context) {
      view
    }
  }
}
#endif
