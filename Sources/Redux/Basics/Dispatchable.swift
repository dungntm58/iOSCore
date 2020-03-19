//
//  Dispatchable.swift
//  RxCoreRedux
//
//  Created by Robert on 8/10/19.
//

public protocol Dispatchable {
    associatedtype Action: Actionable

    func dispatch(type: Action.ActionType, payload: Any)
    func dispatch(_ action: Action...)
    func dispatch(_ actions: [Action])
}
