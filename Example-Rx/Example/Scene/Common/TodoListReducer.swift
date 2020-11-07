//
//  TodoListReducer.swift
//  Example
//
//  Created by Robert on 11/7/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux
import CoreList

class TodoListReducer: Reducible {
    typealias State = TodoList.State
    typealias Action = TodoList.Action
    
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
            return State(list: currentState.list, error: action.payload as? Error)
        case .selectTodo:
            let selectedTodo = currentState.list.data[action.payload as! Int]
            return State(list: currentState.list, selectedTodo: selectedTodo)
        default:
            return currentState
        }
    }
}
