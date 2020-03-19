//
//  Middleware.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 5/16/19.
//

import Combine

public typealias EpicFunction<Action, State> = (_ dispatcher: AnyPublisher<Action, Never>, _ actionStream: AnyPublisher<Action, Never>, _ stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never> where Action: Actionable, State: Statable

public protocol Epic {
    associatedtype Action: Actionable
    associatedtype State: Statable

    func apply(dispatcher: AnyPublisher<Action, Never>, actionStream: AnyPublisher<Action, Never>, stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never>
}
