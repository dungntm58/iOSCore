//
//  TodoInteractor.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreRepository
import CoreRedux
import RxSwift

class TodoCreateEpic: Epic {
    typealias Action = Todo.Action
    typealias State = Todo.State
    
    let worker: TodoWorker
    init() {
        self.worker = TodoWorker()
    }
    
    func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        dispatcher
            .of(type: .createTodo)
            .compactMap { $0.payload as? String }
            .flatMap(worker.createNew)
            .map { Action(type: .createTodoSuccess, payload: $0) }
            .catch { .just($0.toAction()) }
    }
}
