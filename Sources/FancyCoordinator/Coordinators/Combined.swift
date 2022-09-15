//
//  Combined.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Combined<Coordinators: CoordinatorRepresentable>: CoordinatorRepresentable {

    @usableFromInline
    let coordinators: Coordinators

    @inlinable
    public init(@CoordinatorBuilderOf<Coordinators> _ builder: () -> Coordinators) {
        coordinators = builder()
    }

    @inlinable
    public func coordinate(to route: Coordinators.Route, withContext context: Coordinators.Context) -> Coordinators.Scene? {
        coordinators.coordinate(to: route, withContext: context)
    }
}

extension CoordinatorRepresentable {
    // NB: This overload is provided to work around https://github.com/apple/swift/issues/60445
    public func Combined<Route, Scene, Context>(
        @CoordinatorBuilder<Route, Scene, Context> _ build: () -> some CoordinatorRepresentable<Route, Scene, Context>
    ) -> some CoordinatorRepresentable<Route, Scene, Context> {
        FancyCoordinator.Combined(build)
    }
}
