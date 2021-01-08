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
    
    let listReducer: ListReducer
    init() {
        listReducer = ListReducer()
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

extension TodoListReducer {
    class ListReducer: BaseListReducer<TodoEntity, Action> {
        override func merge(currentState: State, newState: State) -> State {
            if newState.isLoading {
                return .init(
                    data: currentState.data,
                    pagination: currentState.pagination,
                    currentPage: currentState.currentPage,
                    pageSize: currentState.pageSize,
                    hasNext: currentState.hasNext,
                    hasPrevious: currentState.hasPrevious,
                    isLoading: newState.isLoading
                )
            }
            return .init(
                data: currentState.data + newState.data,
                pagination: newState.pagination,
                currentPage: newState.currentPage,
                pageSize: newState.pageSize,
                hasNext: newState.hasNext,
                hasPrevious: newState.hasPrevious
            )
        }
    }
}
