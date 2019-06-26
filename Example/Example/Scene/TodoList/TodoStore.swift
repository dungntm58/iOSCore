//
//  Core-CleanSwift-ExampleInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/15/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import CoreRedux
import CoreList

class TodoStore: Store<Todo.Action, TodoReducer> {
    init() {
        super.init(reducer: TodoReducer(), initialState: Todo.State())
        inject(
            TodoListEpic().apply,
            TodoCreateEpic().apply
        )
    }
}

enum TodoActionType: String, ListActionType, ErrorActionType {
    static var updateListState: TodoActionType {
        return ._updateListState
    }
    static var load: TodoActionType {
        return ._load
    }
    static var receiveError: TodoActionType {
        return ._receiveError
    }
    
    case _updateListState
    case _load
    case _receiveError

    case createTodo
}

extension Payload.List {
    struct Request: PayloadListRequestable {
        let page: Int
        let count: Int
        let isAutoRequestCounting: Bool
        let cancelRunning: Bool
        
        init(page: Int, count: Int = 10, isAutoRequestCounting: Bool = true, cancelRunning: Bool) {
            self.page = page
            self.count = count
            self.isAutoRequestCounting = isAutoRequestCounting
            self.cancelRunning = cancelRunning
        }
    }
}
