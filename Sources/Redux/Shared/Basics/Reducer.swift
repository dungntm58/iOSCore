//
//  Reducer.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

public typealias ReduceFunction<Action, State> = (_ action: Action, _ currentState: State) -> State where Action: Actionable, State: Stateable

public protocol Reducible<Action, State> {
    associatedtype State: Stateable
    associatedtype Action: Actionable

    func reduce(action: Action, currentState: State) -> State
}

public extension Reducible {
    func reduce(action: Action, currentState: State) -> State {
        currentState
    }
}
