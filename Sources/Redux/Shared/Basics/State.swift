//
//  State.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/16/19.
//

public protocol Stateable: Equatable {}

precedencegroup ReduxStorePrecedence {
    higherThan: DispatchablePrecedence
    associativity: left
    assignment: true
}

infix operator <|: ReduxStorePrecedence
