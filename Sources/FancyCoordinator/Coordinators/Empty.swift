//
//  Empty.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct Empty<Route, Scene, Context>: CoordinatorRepresentable {
  @inlinable
  public init() {}

  @inlinable
  public func coordinate(to _: Route, withContext _: Context) -> Scene? { nil }
}
