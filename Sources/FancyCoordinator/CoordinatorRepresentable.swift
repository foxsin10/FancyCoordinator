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

    @MainActor
    func coordinate(to route: Route, withContext context: Context) -> Scene?

    @CoordinatorBuilder<Route, Scene, Context>
    @MainActor
    var stack: Self.Stack { get }
}

extension CoordinatorRepresentable where Stack == Never {
    @_transparent
    public var stack: Stack {
        fatalError("\(self) with body refers to never should not call this property directly")
    }
}

extension CoordinatorRepresentable where Stack: CoordinatorRepresentable, Stack.Scene == Scene, Stack.Route == Route, Stack.Context == Context {
    @MainActor
    public func coordinate(to route: Route, withContext context: Context) -> Scene? {
        stack.coordinate(to: route, withContext: context)
    }
}

extension CoordinatorRepresentable where Context == Void {
    @MainActor
    public func coordinate(to route: Route) -> Scene? {
        coordinate(to: route, withContext: ())
    }
}

import SwiftUI

extension CoordinatorRepresentable where Scene: View {
    @ViewBuilder
    @MainActor
    public func buildView(for route: Route, withContext context: Context) -> some View {
        if let view = coordinate(to: route, withContext: context) {
            view
        }
    }
}

