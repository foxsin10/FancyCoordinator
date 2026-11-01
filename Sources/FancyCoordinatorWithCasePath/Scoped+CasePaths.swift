//
//  Scoped+CasePaths.swift
//
//
//  Created by yzj on 2022/9/17.
//

import Foundation

import CasePaths
import FancyCoordinator

public extension Scoped {
  @inlinable
  init<R>(
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
  init<R, C>(
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

public extension CoordinatorRepresentable {
  /// Routes matching `casePath` go to `builder`'s child only; every other route goes to `self` only.
  @inlinable
  func scoped<ChildeRoute, ChildContext, Child: CoordinatorRepresentable>(
    _ casePath: CasePath<Route, ChildeRoute>,
    @CoordinatorBuilder<ChildeRoute, Child.Scene, ChildContext> then builder: () -> Child,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some CoordinatorRepresentable<Route, Scene, Context>
    where
    Context == ChildContext,
    ChildContext == Child.Context,
    ChildeRoute == Child.Route,
    Scene == Child.Scene
  {
    scoped(
      toChildRoute: casePath.extract(from:),
      toChildContext: { .some($0) },
      then: builder,
      file: file,
      fileID: fileID,
      line: line
    )
  }

  /// Routes matching `casePath` go to `builder`'s child only; every other route goes to `self` only.
  /// Returns `nil` when the route matches but the context does not match `toChildContext`.
  @inlinable
  func scoped<ChildeRoute, ChildScene, ChildContext, Child: CoordinatorRepresentable>(
    _ casePath: CasePath<Route, Child.Route>,
    context toChildContext: CasePath<Context, Child.Context>,
    @CoordinatorBuilder<Child.Route, Scene, Child.Context> then builder: () -> Child,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some CoordinatorRepresentable<Route, Scene, Context>
    where
    ChildScene == Scene,
    ChildeRoute == Child.Route,
    ChildContext == Child.Context,
    Scene == Child.Scene
  {
    scoped(
      toChildRoute: casePath.extract(from:),
      toChildContext: toChildContext.extract(from:),
      then: builder,
      file: file,
      fileID: fileID,
      line: line
    )
  }
}
