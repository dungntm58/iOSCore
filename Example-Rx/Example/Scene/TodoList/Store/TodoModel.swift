//
//  TodoRequestModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import Alamofire
import CoreRepository
import CoreList
import CoreRedux

enum Todo {
    enum ActionType: String, ErrorActionType {
        case createTodoSuccess
        case receiveError

        case createTodo

        case logout
        case logoutSuccess
    }
    
    enum Single {
        struct Request: RequestOption {
            let id: String
            
            var parameters: Parameters? { nil }
        }
    }
    
    typealias ViewModel = TodoEntity
    
    struct Action: Actionable {
        typealias ActionType = Todo.ActionType
        
        let type: ActionType
        let payload: Any?
    }
    
    struct State: Stateable, CustomStringConvertible {
        static func == (lhs: Todo.State, rhs: Todo.State) -> Bool {
            if lhs.error == nil && rhs.error == nil {
                return lhs.isLogout == rhs.isLogout
                    && lhs.selectedTodo == rhs.selectedTodo
            }
            return false
        }
        
        var error: Error?
        let selectedTodo: TodoEntity?
        let newTodo: TodoEntity?
        let isLogout: Bool
        
        init(selectedTodo: TodoEntity? = nil, newTodo: TodoEntity? = nil, error: Error? = nil, isLogout: Bool = false) {
            self.selectedTodo = selectedTodo
            self.newTodo = newTodo
            self.error = error
            self.isLogout = isLogout
        }
        
        var description: String {
            """
            Todo.State(
                error: \(error.map(String.init(describing:)) ?? "nil"),
                selectedTodo: \(selectedTodo.map(String.init(describing:)) ?? "nil"),
                isLogout: \(isLogout)
            )
            """
        }
    }
}
