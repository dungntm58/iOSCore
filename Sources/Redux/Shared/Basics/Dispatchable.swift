//
//  Dispatchable.swift
//  CoreRedux
//
//  Created by Robert on 8/10/19.
//

public protocol Dispatchable {
    associatedtype Action: Actionable

    func dispatch(type: Action.ActionType, payload: Any)
    func dispatch(_ action: Action...)
    func dispatch(_ actions: [Action])
}

precedencegroup DispatchablePrecedence {
    associativity: left
    assignment: true
}

infix operator <--: DispatchablePrecedence

@discardableResult
public func <--<D> (dispatcher: D, action: D.Action) -> D where D: Dispatchable {
    dispatcher.dispatch(action)
    return dispatcher
}

@discardableResult
public func <--<D> (dispatcher: D, actions: [D.Action]) -> D where D: Dispatchable {
    dispatcher.dispatch(actions)
    return dispatcher
}
