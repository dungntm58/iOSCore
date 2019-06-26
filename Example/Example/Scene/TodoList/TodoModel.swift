//
//  TodoRequestModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import Alamofire
import CoreBase
import CoreList
import CoreRedux
import DifferenceKit

enum Todo {
    enum Single {
        struct Request: RequestOption {
            let id: String
            
            var parameters: Parameters? {
                return nil
            }
        }
    }
    
    typealias ViewModel = TodoEntity
    
    struct Action: Actionable {
        typealias ActionType = TodoActionType
        
        let type: TodoActionType
        let payload: Any
    }
    
    struct State: Statable {
        let error: ErrorState
        let list: Payload.List.Response<TodoEntity>
        
        init() {
            self.list = Payload.List.Response()
            self.error = ErrorState()
        }
        
        init(list: Payload.List.Response<TodoEntity>, error: ErrorState) {
            self.list = list
            self.error = error
        }
    }
}

extension TodoEntity: CleanViewModelItem, Differentiable {
    var differenceIdentifier: String {
        return id
    }
    
    typealias DifferenceIdentifier = String
    
    func isContentEqual(to source: TodoEntity) -> Bool {
        return title == source.title && completed == source.completed && owner == source.owner && createdAt == source.createdAt
    }
}
