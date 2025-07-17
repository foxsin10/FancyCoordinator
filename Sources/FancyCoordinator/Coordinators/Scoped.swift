//
//  Scoped.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Scoped<
  ParentRoute,
  ParentScene,
  ParentContext,
  Child: CoordinatorRepresentable
>: CoordinatorRepresentable
  where ParentScene == Child.Scene {
  public let toChildRoute: (ParentRoute) -> Child.Route?
  public let toChildContext: (ParentContext) -> Child.Context?
  public let child: Child

  @inlinable
  public init<ChildRoute, ChildContext>(
    toChildRoute: @escaping (ParentRoute) -> ChildRoute?,
    toChildContext: @escaping (ParentContext) -> ChildContext?,
    @CoordinatorBuilder<ChildRoute, ParentScene, ChildContext> then builder: () -> Child
  )
    where
    ChildRoute == Child.Route,
    ChildContext == Child.Context
  {
    self.toChildRoute = toChildRoute
    self.toChildContext = toChildContext
    child = builder()
  }

  @inlinable
  public func coordinate(to route: ParentRoute, withContext context: ParentContext) -> ParentScene? {
    guard let childRoute = toChildRoute(route),
          let childContext = toChildContext(context) else {
      return nil
    }

    return child.coordinate(to: childRoute, withContext: childContext)
  }
}

public extension CoordinatorRepresentable {
  @inlinable
  func scoped(
    _ toChildRoute: @escaping (Route) -> Route?
  ) -> some CoordinatorRepresentable<Route, Scene, Context> {
    FancyCoordinator.Scoped(
      toChildRoute: toChildRoute,
      toChildContext: { .some($0) },
      then: { self }
    )
  }

  @inlinable
  func scoped<ChildRoute, ChildContext, Child: CoordinatorRepresentable>(
    toChildRoute: @escaping (Route) -> ChildRoute?,
    toChildContext: @escaping (Context) -> ChildContext?,
    @CoordinatorBuilder<ChildRoute, Scene, ChildContext> then builder: () -> Child
  ) -> some CoordinatorRepresentable<Route, Scene, Context>
    where
    Scene == Child.Scene,
    ChildRoute == Child.Route,
    ChildContext == Child.Context {
    FancyCoordinator.Scoped(
      toChildRoute: toChildRoute,
      toChildContext: toChildContext,
      then: builder
    )
  }
}
