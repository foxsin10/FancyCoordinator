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
    public init(_ casePath: CasePath<Route, Child.Route>, @CoordinatorBuilderOf<Child> then childBuilder: () -> Child) {
        self.init(casePath.extract(from:), then: childBuilder)
    }
}

extension CoordinatorRepresentable {
    @inlinable
    public func scoped(
        _ casePath: CasePath<Route, Route>
    ) -> some CoordinatorRepresentable<Route, Scene, Context> {
        FancyCoordinator.Scoped(casePath.extract(from:)) {
            self
        }
    }

    @inlinable
    public func scoped<Child: CoordinatorRepresentable>(
        _ casePath: CasePath<Route, Child.Route>,
        @CoordinatorBuilderOf<Child> then builder: () -> Child
    ) -> some CoordinatorRepresentable<Route, Child.Scene, Child.Context> {
        FancyCoordinator.Scoped(casePath.extract(from:), then: builder)
    }
}
