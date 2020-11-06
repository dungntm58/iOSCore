//
//  TodoListEpic.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux
import CoreRepository

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
