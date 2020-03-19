//
//  LoginEpic.swift
//  Example
//
//  Created by Robert on 8/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxCoreBase
import RxCoreRedux
import RxSwift

class LoginEpic: Epic {
    typealias Action = Login.Action
    typealias State = Login.State
    
    let worker: UserWorker
    
    init() {
        self.worker = UserWorker()
    }
    
    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        dispatcher
            .of(type: .login)
            .map { $0.payload as! (String, String) }
            .flatMap { self.worker.login(userName: $0.0, password: $0.1) }
            .map { Action(type: .success, payload: $0) }
            .catchError { .just($0.toAction()) }
    }
}

class RegisterEpic: Epic {
    typealias Action = Login.Action
    typealias State = Login.State
    
    let worker: UserWorker
    
    init() {
        self.worker = UserWorker()
    }
    
    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        dispatcher
            .of(type: .register)
            .map { $0.payload as! (String, String) }
            .flatMap { self.worker.signup(userName: $0.0, password: $0.1) }
            .map { Action(type: .success, payload: $0) }
            .catchError { .just($0.toAction()) }
    }
}
