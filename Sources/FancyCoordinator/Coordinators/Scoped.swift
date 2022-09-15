//
//  Scoped.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Scoped<Route, Child: CoordinatorRepresentable>: CoordinatorRepresentable {
    public typealias Context = Child.Context
    public typealias Scene = Child.Scene

    public let toChildeRoute: (Route) -> Child.Route?
    public let child: Child

    @inlinable
    public init(
        _ toChildRoute: @escaping (Route) -> Child.Route?,
        @CoordinatorBuilderOf<Child> then builder: () -> Child
    ) {
        self.toChildeRoute = toChildRoute
        self.child = builder()
    }

    @inlinable
    public func coordinate(to route: Route, withContext context: Child.Context) -> Child.Scene? {
        guard let childRoute = toChildeRoute(route) else {
            return nil
        }

        return child.coordinate(to: childRoute, withContext: context)
    }
}

extension CoordinatorRepresentable {
    @inlinable
    public func scoped(
        _ toChildRoute: @escaping (Route) -> Route?
    ) -> some CoordinatorRepresentable<Route, Scene, Context> {
        FancyCoordinator.Scoped(toChildRoute) {
            self
        }
    }

    @inlinable
    public func scoped<Child: CoordinatorRepresentable>(
        _ toChildRoute: @escaping (Route) -> Child.Route?,
        @CoordinatorBuilderOf<Child> then builder: () -> Child
    ) -> some CoordinatorRepresentable<Route, Child.Scene, Child.Context> {
        FancyCoordinator.Scoped(toChildRoute, then: builder)
    }
}
