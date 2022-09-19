//
//  Scoped.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Scoped<Route, Context, Child: CoordinatorRepresentable>: CoordinatorRepresentable {
    public typealias Scene = Child.Scene

    public let toChildRoute: (Route) -> Child.Route?
    public let toChildContext: (Context) -> Child.Context?
    public let child: Child

    @inlinable
    public init(
        _ toChildRoute: @escaping (Route) -> Child.Route?,
        toChildContext: @escaping (Context) -> Child.Context?,
        @CoordinatorBuilderOf<Child> then builder: () -> Child
    ) {
        self.toChildRoute = toChildRoute
        self.toChildContext = toChildContext
        self.child = builder()
    }

    @inlinable
    public func coordinate(to route: Route, withContext context: Context) -> Scene? {
        guard let childRoute = toChildRoute(route),
              let childContext = toChildContext(context) else {
            return nil
        }

        return child.coordinate(to: childRoute, withContext: childContext)
    }
}

extension CoordinatorRepresentable {
    @inlinable
    public func scoped(
        _ toChildRoute: @escaping (Route) -> Route?
    ) -> some CoordinatorRepresentable<Route, Scene, Context> {
        FancyCoordinator.Scoped(toChildRoute, toChildContext: { $0 }) {
            self
        }
    }

    @inlinable
    public func scoped<Child: CoordinatorRepresentable>(
        _ toChildRoute: @escaping (Route) -> Child.Route?,
        toChildContext: @escaping (Context) -> Child.Context?,
        @CoordinatorBuilderOf<Child> then builder: () -> Child
    ) -> some CoordinatorRepresentable<Route, Child.Scene, Context> {
        FancyCoordinator.Scoped(toChildRoute, toChildContext: toChildContext, then: builder)
    }
}
