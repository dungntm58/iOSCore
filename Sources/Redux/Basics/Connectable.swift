//
//  Connectable.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift

public protocol Connectable {
    associatedtype Store: Storable

    var store: Store { get }
}

public extension Connectable where Self: Dispatchable, Store: Dispatchable, Store.Action == Action {
    func dispatch(type: Action.ActionType, payload: Any) {
        store.dispatch(type: type, payload: payload)
    }

    func dispatch(_ action: Action...) {
        store.dispatch(action)
    }

    func dispatch(_ actions: [Action]) {
        store.dispatch(actions)
    }
}
