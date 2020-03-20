//
//  LoginEpic.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import CoreBase
import CoreRedux
import Combine

class LoginEpic: Epic {
    typealias Action = Login.Action
    typealias State = Login.State
    
    let worker: UserWorker
    
    init() {
        self.worker = UserWorker()
    }
    
    func apply(dispatcher: AnyPublisher<Action, Never>, actionStream: AnyPublisher<Action, Never>, stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never> {
        dispatcher
            .of(type: .login)
            .map { $0.payload as! (String, String) }
            .flatMap ({
                self.worker.login(userName: $0.0, password: $0.1)
                    .map { Action(type: .success, payload: $0) }
                    .catch { Just($0.toAction()) }
            })
            .eraseToAnyPublisher()
    }
}

class RegisterEpic: Epic {
    typealias Action = Login.Action
    typealias State = Login.State
    
    let worker: UserWorker
    
    init() {
        self.worker = UserWorker()
    }
    
    func apply(dispatcher: AnyPublisher<Action, Never>, actionStream: AnyPublisher<Action, Never>, stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never> {
        dispatcher
            .of(type: .register)
            .map { $0.payload as! (String, String) }
            .flatMap ({
                self.worker.signup(userName: $0.0, password: $0.1)
                    .map { Action(type: .success, payload: $0) }
                    .catch { Just($0.toAction()) }
            })
            .eraseToAnyPublisher()
    }
}
