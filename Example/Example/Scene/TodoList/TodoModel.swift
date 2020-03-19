//
//  TodoRequestModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import Alamofire
import RxCoreRepository
import RxCoreList
import RxCoreRedux
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
        let payload: Any
    }
    
    struct State: Statable, CustomStringConvertible {
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

extension TodoEntity: ViewModelItem, Differentiable {
    var differenceIdentifier: String { id }
    
    typealias DifferenceIdentifier = String
    
    func isContentEqual(to source: TodoEntity) -> Bool {
        title == source.title
            && completed == source.completed
            && owner == source.owner
            && createdAt == source.createdAt
    }
}
