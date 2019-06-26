//
//  TodoService.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import SwiftDate
import CoreBase
import CoreList

class TodoWorker: ListDataWorker {
    let todoRepository: TodoRepository
    
    init() {
        todoRepository = TodoRepository()
    }
    
    func getList(options: PaginationRequest?) -> Observable<ListResponse<TodoEntity>> {
        return todoRepository.getList(options: options)
    }
    
    func createNew(_ title: String) -> Observable<TodoEntity> {
        return todoRepository.create(TodoEntity(title: title), options: nil)
    }
}
