//
//  Action.swift
//  CoreCleanSwiftRedux
//
//  Created by Robert Nguyen on 6/4/19.
//

public protocol Actionable {
    associatedtype ActionType: Equatable

    var type: ActionType { get }
    var payload: Any { get }

    init(type: ActionType, payload: Any)
}

public protocol ErrorActionType: Equatable {
    static var receiveError: Self { get }
}

public struct ErrorState: Error, Statable {
    public let error: Error?
    public init(error: Error? = nil) {
        self.error = error
    }

    public func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ErrorActionType {
        return Action(type: .receiveError, payload: self)
    }
}
