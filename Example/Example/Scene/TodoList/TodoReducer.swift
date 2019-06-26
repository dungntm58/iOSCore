//
//  Core-CleanSwift-ExamplePresenter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreRedux
import CoreList

class TodoReducer: Reducable {
    typealias State = Todo.State
    typealias Action = Todo.Action
    
    let listReducer: BaseListReducer<TodoEntity, Action>
    let errorReducer: ErrorReducer<Action>
    init() {
        listReducer = BaseListReducer()
        errorReducer = ErrorReducer()
    }
    
    func reduce(action: Action, currentState: State) -> State {
        let newList = listReducer.reduce(action: action, currentState: currentState.list)
        let error = errorReducer.reduce(action: action, currentState: currentState.error)
        return State(list: newList, error: error)
    }
}

class ErrorReducer<Action>: Reducable where Action: Actionable, Action.ActionType: ErrorActionType {
    typealias State = ErrorState
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .receiveError:
            return action.payload as! State
        default:
            return currentState
        }
    }
}
