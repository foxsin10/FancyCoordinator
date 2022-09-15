//
//  IfLet.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

public struct IfLet<Parent: CoordinatorRepresentable, Child: CoordinatorRepresentable>: CoordinatorRepresentable {
    @usableFromInline
    let parent: Parent

    @usableFromInline
    let child: Child

    @usableFromInline
    let toChildRoute: (Parent.Route) -> Child.Route?

    @usableFromInline
    let file: StaticString

    @usableFromInline
    let fileID: StaticString

    @usableFromInline
    let line: UInt

    @inlinable
    init(
        parent: Parent,
        child: Child,
        toChildRoute: @escaping (Parent.Route) -> Child.Route?,
        file: StaticString,
        fileID: StaticString,
        line: UInt
    ) {
        self.parent = parent
        self.child = child
        self.toChildRoute = toChildRoute
        self.file = file
        self.fileID = fileID
        self.line = line
    }

    @inlinable
    public func coordinate(to route: Parent.Route, withContext context: Child.Context) -> Child.Scene? {
        guard let childRoute = toChildRoute(route) else {
            return nil
        }

        return child.coordinate(to: childRoute, withContext: context)
    }
}

extension CoordinatorRepresentable {
    public func ifLet<C: CoordinatorRepresentable>(
        _ toChildeRoute: @escaping (Route) -> C.Route?,
        @CoordinatorBuilderOf<C> then wrapped: () -> C,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some CoordinatorRepresentable<Route, C.Scene, C.Context> {
        FancyCoordinator.IfLet(
            parent: self,
            child: wrapped(),
            toChildRoute: toChildeRoute,
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
