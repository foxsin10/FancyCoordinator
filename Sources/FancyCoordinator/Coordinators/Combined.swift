//
//  Combined.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Combined<
  Route,
  Scene,
  Context,
  Coordinators: CoordinatorRepresentable
>: CoordinatorRepresentable
  where
  Route == Coordinators.Route,
  Scene == Coordinators.Scene,
  Context == Coordinators.Context {
  @usableFromInline
  let coordinators: Coordinators

  @inlinable
  public init(
    @CoordinatorBuilder<Route, Scene, Context>
    _ builder: () -> Coordinators
  ) {
    coordinators = builder()
  }

  @inlinable
  public func coordinate(
    to route: Coordinators.Route,
    withContext context: Coordinators.Context
  ) -> Coordinators.Scene? {
    coordinators.coordinate(to: route, withContext: context)
  }
}
