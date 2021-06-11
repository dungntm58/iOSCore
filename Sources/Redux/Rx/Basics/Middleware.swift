//
//  Middleware.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/16/19.
//

import RxSwift

public typealias EpicFunction<Action, State> = (
    _ dispatcher: Observable<Action>,
    _ actionStream: Observable<Action>,
    _ stateStream: Observable<State>
) -> Observable<Action> where Action: Actionable, State: Stateable

public protocol Epic {
    associatedtype Action: Actionable
    associatedtype State: Stateable

    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action>
}

extension Epic {
    public func eraseToAny() -> AnyEpic<Action, State> { .init(self) }
}

@frozen
public struct AnyEpic<Action, State>: Epic where Action: Actionable, State: Stateable {
    @usableFromInline
    let epicFunction: EpicFunction<Action, State>

    init<E>(_ epic: E) where E: Epic, E.Action == Action, E.State == State {
        if let any = epic as? AnyEpic {
            self = any
        } else {
            epicFunction = epic.apply
        }
    }

    @inlinable
    public func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        epicFunction(dispatcher, actionStream, stateStream)
    }
}
