//
//  IfLet.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct IfLet<Parent: CoordinatorRepresentable, Child: CoordinatorRepresentable>: CoordinatorRepresentable where Parent.Scene == Child.Scene {
    @usableFromInline
    let parent: Parent

    @usableFromInline
    let child: Child

    @usableFromInline
    let toChildRoute: (Parent.Route) -> Child.Route?

    @usableFromInline
    let toChildContext: (Parent.Context) -> Child.Context

    @usableFromInline
    let file: StaticString

    @usableFromInline
    let fileID: StaticString

    @usableFromInline
    let line: UInt

    @inlinable
    public init(
        parent: Parent,
        child: Child,
        toChildRoute: @escaping (Parent.Route) -> Child.Route?,
        toChildContext: @escaping (Parent.Context) -> Child.Context,
        file: StaticString,
        fileID: StaticString,
        line: UInt
    ) {
        self.parent = parent
        self.child = child
        self.toChildRoute = toChildRoute
        self.toChildContext = toChildContext
        self.file = file
        self.fileID = fileID
        self.line = line
    }

    @inlinable
    public func coordinate(to route: Parent.Route, withContext context: Parent.Context) -> Child.Scene? {
        guard let childRoute = toChildRoute(route) else {
            return parent.coordinate(to: route, withContext: context)
        }

        return child.coordinate(to: childRoute, withContext: toChildContext(context))
    }
}

extension CoordinatorRepresentable {
    public func ifLet<ChildRoute, ChildScene, ChildContext, C: CoordinatorRepresentable>(
        _ toChildeRoute: @escaping (Route) -> C.Route?,
        @CoordinatorBuilder<ChildRoute, ChildScene, ChildContext> then wrapped: () -> C,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some CoordinatorRepresentable<Route, Scene, Context> where Scene == C.Scene, C.Context == Context {
        FancyCoordinator.IfLet(
            parent: self,
            child: wrapped(),
            toChildRoute: toChildeRoute,
            toChildContext: { $0 },
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
