//
//  Action.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 6/4/19.
//

public protocol Actionable: CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype ActionType: Equatable

    var type: ActionType { get }
    var payload: Any { get }

    init(type: ActionType, payload: Any)
}

extension Actionable {
    public var description: String {
        "\(Self.self)(type: \(String(describing: type)), payload: \(String(describing: payload)))"
    }

    public var debugDescription: String {
        "\(Self.self)(type: \(String(describing: type)), payload: \(String(describing: payload)))"
    }
}

public protocol ErrorActionType: Equatable {
    static var receiveError: Self { get }
}

public extension Error {
    func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ErrorActionType {
        .init(type: .receiveError, payload: self)
    }
}
