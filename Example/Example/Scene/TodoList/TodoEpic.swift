//
//  TodoInteractor.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreRepository
import CoreRedux
import CoreList
import Combine

class TodoListEpic: BaseListEpic<Todo.Action, Todo.State, TodoWorker> {
    init() {
        super.init(worker: TodoWorker())
    }
    
    override func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        payload as? PaginationRequestOptions
    }
}

extension Payload.List.Request: PaginationRequestOptions {
    var requestOptions: RequestOption? {
        [
            "page": page
        ]
    }
    
    var repositoryOptions: RepositoryOption { .default }
    
    var storeFetchOptions: DataStoreFetchOption {
        .page(page, size: count, predicate: nil, sorting: [.desc(property: "createdAt")], validate: true)
    }
}

class TodoCreateEpic: Epic {
    typealias Action = Todo.Action
    typealias State = Todo.State
    
    let worker: TodoWorker
    init() {
        self.worker = TodoWorker()
    }
    
    func apply(dispatcher: AnyPublisher<Action, Never>, actionStream: AnyPublisher<Action, Never>, stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never> {
        dispatcher
            .of(type: .createTodo)
            .compactMap { $0.payload as? String }
            .flatMap ({
                [weak self] payload -> AnyPublisher<Action, Never> in
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.worker.createNew(payload)
                    .map { Payload.List.Response(data: [$0]) }
                    .map { res -> Action in res.toAction() }
                    .catch { Just($0.toAction()) }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
