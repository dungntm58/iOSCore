//
//  TodoList.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux

enum TodoList {
    enum ActionType: String, ListActionType {
        case updateListState
        case load
        case receiveError
        
        case selectTodo
    }
    
    struct Action: Actionable {
        typealias ActionType = TodoList.ActionType
        
        let type: ActionType
        let payload: Any?
    }
    
    struct State: Stateable, CustomStringConvertible {
        static func == (lhs: TodoList.State, rhs: TodoList.State) -> Bool {
            if lhs.error == nil && rhs.error == nil {
                return lhs.list == rhs.list
                    && lhs.selectedTodo == rhs.selectedTodo
            }
            return false
        }
        
        let error: Error?
        let list: Payload.List.Response<TodoEntity>
        let selectedTodo: TodoEntity?
        
        init() {
            self.list = Payload.List.Response()
            self.selectedTodo = nil
            self.error = nil
        }
        
        init(list: Payload.List.Response<TodoEntity> = .init(), selectedTodo: TodoEntity? = nil, error: Error? = nil) {
            self.list = list
            self.selectedTodo = selectedTodo
            self.error = error
        }
        
        var description: String {
            """
            Todo.State(
                error: \(error.map(String.init(describing:)) ?? "nil"),
                list: \(String(describing: list)),
                selectedTodo: \(selectedTodo.map(String.init(describing:)) ?? "nil")
            )
            """
        }
    }
}
