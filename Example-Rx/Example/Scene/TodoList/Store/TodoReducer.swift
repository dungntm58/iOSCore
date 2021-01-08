//
//  Core-CleanSwift-ExamplePresenter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreRedux
import CoreList

class TodoReducer: Reducible {
    typealias State = Todo.State
    typealias Action = Todo.Action
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .createTodoSuccess:
            return State(newTodo: action.payload as? TodoEntity)
        case .receiveError:
            return State(error: action.payload as? Error)
        case .logoutSuccess:
            return State(isLogout: true)
        default:
            return currentState
        }
    }
}
