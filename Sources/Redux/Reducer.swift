//
//  Reducer.swift
//  CoreCleanSwiftRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import Foundation

public protocol Reducable {
    associatedtype State: Statable
    associatedtype Action: Actionable

    func reduce(action: Action, currentState: State) -> State
}

public extension Reducable {
    func reduce(action: Action, currentState: State) -> State {
        return currentState
    }
}
