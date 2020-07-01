//
//  Middleware.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/16/19.
//

import RxSwift

public typealias EpicFunction<Action, State> = (_ dispatcher: Observable<Action>, _ actionStream: Observable<Action>, _ stateStream: Observable<State>) -> Observable<Action> where Action: Actionable, State: Stateable

public protocol Epic {
    associatedtype Action: Actionable
    associatedtype State: Stateable

    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action>
}
