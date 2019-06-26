//
//  Middleware.swift
//  CoreCleanSwiftRedux
//
//  Created by Robert Nguyen on 5/16/19.
//

import RxSwift

public typealias EpicFunction<Action, State> = (_ action: Observable<Action>, _ state: Observable<State>) -> Observable<Action> where Action: Actionable, State: Statable

public protocol Epic {
    associatedtype Action: Actionable
    associatedtype State: Statable

    func apply(action: Observable<Action>, state: Observable<State>) -> Observable<Action>
}
