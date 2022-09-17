//
//  IfLet+CasePath.swift
//
//
//  Created by yzj on 2022/9/17.
//

import Foundation

import CasePaths
import FancyCoordinator

extension IfLet {
    @inlinable
    public init(
        parent: Parent,
        child: Child,
        toChildCasePath casePath: CasePath<Parent.Route, Child.Route>,
        toChildContext: @escaping (Parent.Context) -> Child.Context,
        file: StaticString,
        fileID: StaticString,
        line: UInt
    ) {
        self.init(
            parent: parent,
            child: child,
            toChildRoute: casePath.extract(from:),
            toChildContext: toChildContext,
            file: file,
            fileID: fileID,
            line: line
        )
    }
}

extension CoordinatorRepresentable {
    @inlinable
    public func ifLet<C: CoordinatorRepresentable>(
        _ casePath: CasePath<Route, C.Route>,
        @CoordinatorBuilderOf<C> then wrapped: () -> C,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some CoordinatorRepresentable<Route, C.Scene, C.Context> where C.Context == Context, C.Scene == Scene {
        FancyCoordinator.IfLet(
            parent: self,
            child: wrapped(),
            toChildCasePath: casePath,
            toChildContext: { $0 },
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
