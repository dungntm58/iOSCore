//
//  TodoService.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Combine
import SwiftDate
import CoreRepository
import CoreRedux
import CoreReduxList

class TodoWorker: ListDataWorker {
    let todoRepository: TodoRepository
    
    init() {
        todoRepository = TodoRepository()
    }
    
    func getList(options: PaginationRequestOptions?) -> AnyPublisher<ListDTO<TodoEntity>, Error> {
        todoRepository.getList(options: options)
    }
    
    func createNew(_ title: String) -> AnyPublisher<TodoEntity, Error> {
        todoRepository.create(TodoEntity(title: title), options: nil)
    }
}
