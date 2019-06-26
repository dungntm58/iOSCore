//
//  TodoInteractor.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase
import CoreRedux
import CoreList
import RxSwift

class TodoListEpic: BaseListEpic<Todo.Action, Todo.State, TodoWorker> {
    init() {
        super.init(worker: TodoWorker())
    }
    
    override func toPaginationRequest(from payload: PayloadListRequestable?) -> PaginationRequest? {
        return payload as? PaginationRequest
    }
}

extension Payload.List.Request: PaginationRequest {
    var requestOptions: RequestOption? {
        return [
            "page": page
        ]
    }
    
    var repositoryOptions: RepositoryOption {
        return .default
    }
    
    var storeFetchOptions: DataStoreFetchOption {
        return .page(page, size: count, predicate: nil, sorting: .desc(property: "createdAt"), validate: true)
    }
}

class TodoCreateEpic: Epic {
    typealias Action = Todo.Action
    typealias State = Todo.State
    
    let worker: TodoWorker
    init() {
        self.worker = TodoWorker()
    }
    
    func apply(action: Observable<Action>, state: Observable<State>) -> Observable<Action> {
        return action
            .of(type: .createTodo)
            .compactMap { $0.payload as? String }
            .flatMap(worker.createNew)
            .map { Payload.List.Response(data: [$0]) }
            .map { $0.toAction() }
            .catchError { .just(ErrorState(error: $0).toAction()) }
    }
}
