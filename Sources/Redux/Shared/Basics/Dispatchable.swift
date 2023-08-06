//
//  Dispatchable.swift
//  CoreRedux
//
//  Created by Robert on 8/10/19.
//

public protocol Dispatchable {
    associatedtype Action: Actionable

    func dispatch(type: Action.ActionType, payload: Any?)
    func dispatch(_ actions: [Action])
}

extension Dispatchable {
    @inlinable
    public func dispatch(type: Action.ActionType) {
        dispatch(type: type, payload: nil)
    }

    @inlinable
    public func dispatch(_ action: Action...) {
        dispatch(action)
    }
}

precedencegroup DispatchablePrecedence {
    associativity: left
    assignment: true
}

infix operator <--: DispatchablePrecedence

@discardableResult
@inlinable
public func <--<D> (dispatcher: D, action: D.Action.ActionType) -> D where D: Dispatchable {
    dispatcher.dispatch(D.Action(type: action, payload: nil))
    return dispatcher
}

@discardableResult
@inlinable
public func <--<D> (dispatcher: D, action: D.Action) -> D where D: Dispatchable {
    dispatcher.dispatch(action)
    return dispatcher
}

@discardableResult
@inlinable
public func <--<D> (dispatcher: D, actions: [D.Action]) -> D where D: Dispatchable {
    dispatcher.dispatch(actions)
    return dispatcher
}
