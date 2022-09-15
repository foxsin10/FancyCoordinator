//
//  CoordinatorBuilder.swift
//
//
//  Created by yzj on 2022/9/15.
//

import Foundation

@resultBuilder
public enum CoordinatorBuilder<Route, Scene, Context> {
    @inlinable
    public static func buildArray<C: CoordinatorRepresentable>(_ components: [C]) -> SequensedMany<C>
        where C.Scene == Scene, C.Route == Route, C.Context == Context {
        SequensedMany(coordinators: components)
    }

    @inlinable
    public static func buildBlock() -> Empty<Route, Scene, Context> {
        FancyCoordinator.Empty()
    }

    @inlinable
    public static func buildBlock<C: CoordinatorRepresentable>(_ coordinator: C) -> C
        where C.Route == Route, C.Scene == Scene, C.Context == Context {
        coordinator
    }

    @inlinable
    public static func buildEither<C0: CoordinatorRepresentable, C1: CoordinatorRepresentable>(first component: C0) -> ConditionCoordinator<C0, C1>
        where C0.Route == Route, C0.Scene == Scene, C0.Context == Context {
        .first(component)
    }

    @inlinable
    public static func buildEither<C0: CoordinatorRepresentable, C1: CoordinatorRepresentable>(second component: C1) -> ConditionCoordinator<C0, C1>
        where C0.Route == Route, C0.Scene == Scene, C0.Context == Context {
        .second(component)
    }

    @inlinable
    public static func buildExpression<C: CoordinatorRepresentable>(_ expression: C) -> C
        where C.Scene == Scene, C.Route == Route, C.Context == Context {
        expression
    }

    @inlinable
    public static func buildFinalResult<C: CoordinatorRepresentable>(_ component: C) -> C
        where C.Scene == Scene, C.Route == Route, C.Context == Context {
        component
    }

    @inlinable
    public static func buildLimitedAvailability<C: CoordinatorRepresentable>(_ component: C) -> OptionalCoordinator<C>
        where C.Route == Route, C.Scene == Scene, C.Context == Context {
        OptionalCoordinator(wrapped: component)
    }

    @inlinable
    public static func buildOptional<C: CoordinatorRepresentable>(_ component: C?) -> OptionalCoordinator<C>
        where C.Route == Route, C.Scene == Scene, C.Context == Context {
        OptionalCoordinator(wrapped: component)
    }

    @inlinable
    public static func buildPartialBlock<C: CoordinatorRepresentable>(first: C) -> C
        where C.Route == Route, C.Scene == Scene, C.Context == Context {
        first
    }

    @inlinable
    public static func buildPartialBlock<C0: CoordinatorRepresentable, C1: CoordinatorRepresentable>(
        accumulated: C0, next: C1
    ) -> Sequenced<C0, C1>
        where C0.Scene == Scene, C0.Route == Route, C0.Context == Context {
        Sequenced(c0: accumulated, c1: next)
    }
}

extension CoordinatorBuilder {
    public struct Sequenced<C0: CoordinatorRepresentable, C1: CoordinatorRepresentable>: CoordinatorRepresentable
        where C0.Route == C1.Route, C0.Scene == C1.Scene, C0.Context == C1.Context {
        @usableFromInline
        let c0: C0

        @usableFromInline
        let c1: C1

        @inlinable
        init(c0: C0, c1: C1) {
            self.c0 = c0
            self.c1 = c1
        }

        @inlinable
        public func coordinate(to route: C0.Route, withContext context: C0.Context) -> C0.Scene? {
            if let scene = c0.coordinate(to: route, withContext: context) {
                return scene
            }

            if let scene = c1.coordinate(to: route, withContext: context) {
                return scene
            }

            return nil
        }
    }

    public struct SequensedMany<Element: CoordinatorRepresentable>: CoordinatorRepresentable {
        @usableFromInline
        let coordinators: [Element]

        @inlinable
        init(coordinators: [Element]) {
            self.coordinators = coordinators
        }

        @inlinable
        public func coordinate(to route: Element.Route, withContext context: Element.Context) -> Element.Scene? {
            for coordinator in coordinators {
                guard let scene = coordinator.coordinate(to: route, withContext: context) else {
                    continue
                }

                return scene
            }

            return nil
        }
    }

    public enum ConditionCoordinator<First: CoordinatorRepresentable, Second: CoordinatorRepresentable>: CoordinatorRepresentable
        where First.Route == Second.Route, First.Scene == Second.Scene, First.Context == Second.Context {
        case first(First)
        case second(Second)

        @inlinable
        public func coordinate(to route: First.Route, withContext context: First.Context) -> First.Scene? {
            switch self {
            case let .first(first): return first.coordinate(to: route, withContext: context)
            case let .second(second): return second.coordinate(to: route, withContext: context)
            }
        }
    }

    public struct OptionalCoordinator<Wrapped: CoordinatorRepresentable>: CoordinatorRepresentable
        where Route == Wrapped.Route, Scene == Wrapped.Scene, Context == Wrapped.Context {
        @usableFromInline
        let wrapped: Wrapped?

        @inlinable
        init(wrapped: Wrapped?) {
            self.wrapped = wrapped
        }

        @inlinable
        public func coordinate(to route: Wrapped.Route, withContext context: Wrapped.Context) -> Wrapped.Scene? {
            wrapped?.coordinate(to: route, withContext: context)
        }
    }
}

public typealias CoordinatorBuilderOf<C: CoordinatorRepresentable> = CoordinatorBuilder<C.Route, C.Scene, C.Context>
