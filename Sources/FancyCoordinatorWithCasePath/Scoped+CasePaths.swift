//
//  Scoped+CasePaths.swift
//
//
//  Created by yzj on 2022/9/17.
//

import Foundation

import CasePaths
import FancyCoordinator

extension Scoped {
    @inlinable
    public init<R>(
        _ casePath: CasePath<ParentRoute, R>,
        @CoordinatorBuilder<R, Scene, Context> then childBuilder: () -> Child
    )
        where
        R == Child.Route,
        Context == Child.Context
    {
        self.init(
            toChildRoute: casePath.extract(from:),
            toChildContext: { .some($0) },
            then: childBuilder
        )
    }

    @inlinable
    public init<R, C>(
        _ casePath: CasePath<ParentRoute, R>,
        context toChildContext: CasePath<ParentContext, C>,
        @CoordinatorBuilder<R, Scene, C> then childBuilder: () -> Child
    )
        where
        R == Child.Route,
        C == Child.Context {
        self.init(
            toChildRoute: casePath.extract(from:),
            toChildContext: toChildContext.extract(from:),
            then: childBuilder
        )
    }
}

extension CoordinatorRepresentable {
    @inlinable
    public func scoped<ChildeRoute, ChildScene, ChildContext, Child: CoordinatorRepresentable>(
        _ casePath: CasePath<Route, ChildeRoute>,
        @CoordinatorBuilder<ChildeRoute, ChildScene, ChildContext> then builder: () -> Child
    ) -> some CoordinatorRepresentable<Route, Scene, Context>
        where
        Context == ChildContext,
        ChildContext == Child.Context,
        ChildScene == Child.Scene,
        ChildeRoute == Child.Route,
        Scene == Child.Scene
    {
        FancyCoordinator.Scoped<Route, Scene, Context, Child>(
            toChildRoute: casePath.extract(from:),
            toChildContext: { $0 },
            then: builder
        )
    }

    @inlinable
    public func scoped<ChildeRoute, ChildScene, ChildContext, Child: CoordinatorRepresentable>(
        _ casePath: CasePath<Route, Child.Route>,
        context toChildContext: CasePath<Context, Child.Context>,
        @CoordinatorBuilder<Child.Route, Scene, Child.Context> then builder: () -> Child
    ) -> some CoordinatorRepresentable<Route, Scene, Context>
        where
        ChildScene == Scene,
        ChildeRoute == Child.Route,
        ChildContext == Child.Context,
        Scene == Child.Scene
    {
        FancyCoordinator.Scoped(
            toChildRoute: casePath.extract(from:),
            toChildContext: toChildContext.extract(from:),
            then: builder
        )
    }
}
