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
import CoreReduxList
import DifferenceKit

enum Todo {
    enum Single {
        struct Request: RequestOption {
            let id: String
            
            var parameters: Parameters? { nil }
        }
    }
    
    typealias ViewModel = TodoEntity
    
    struct Action: Actionable {
        typealias ActionType = TodoActionType
        
        let type: TodoActionType
        let payload: Any?
    }
    
    struct State: Stateable, CustomStringConvertible {
        static func == (lhs: Todo.State, rhs: Todo.State) -> Bool {
            if lhs.error == nil && rhs.error == nil {
                return lhs.isLogout == rhs.isLogout
                    && lhs.list == rhs.list
                    && lhs.selectedTodoIndex == rhs.selectedTodoIndex
            }
            return false
        }
        
        var error: Error?
        let list: Payload.List.Response<TodoEntity>
        let selectedTodoIndex: Int
        let isLogout: Bool
        
        init() {
            self.list = Payload.List.Response()
            self.selectedTodoIndex = -1
            self.error = nil
            self.isLogout = false
        }
        
        init(list: Payload.List.Response<TodoEntity>, selectedTodoIndex: Int = -1, error: Error? = nil, isLogout: Bool = false) {
            self.list = list
            self.selectedTodoIndex = selectedTodoIndex
            self.error = error
            self.isLogout = isLogout
        }
        
        var description: String {
            """
            Todo.State(
                error: \(error.map(String.init(describing:)) ?? "nil"),
                list: \(String(describing: list)),
                selectedTodoIndex: \(selectedTodoIndex),
                isLogout: \(isLogout)
            )
            """
        }
    }
}
