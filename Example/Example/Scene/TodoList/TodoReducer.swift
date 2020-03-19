//
//  Core-CleanSwift-ExamplePresenter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreRedux
import RxCoreList

class TodoReducer: Reducable {
    typealias State = Todo.State
    typealias Action = Todo.Action
    
    let listReducer: BaseListReducer<TodoEntity, Action>
    init() {
        listReducer = BaseListReducer()
    }
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .updateListState:
            let newList = listReducer.reduce(action: action, currentState: currentState.list)
            return State(list: newList)
        case .receiveError:
            return State(list: Payload.List.Response<TodoEntity>(), error: action.payload as? Error)
        case .selectTodo:
            return State(list: currentState.list, selectedTodoIndex: action.payload as! Int)
        case .logoutSuccess:
            return State(list: currentState.list, error: currentState.error, isLogout: true)
        default:
            return currentState
        }
    }
}
