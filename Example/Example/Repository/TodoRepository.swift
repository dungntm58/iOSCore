//
//  TodoRepository.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreRepository

class TodoRepository: RemoteIdentifiableSingleRepository, RemoteListRepository {
    typealias T = TodoEntity
    
//    let store: TodoDataStore
    let singleRequest: TodoSingleRequest
    let listRequest: TodoListRequest
    
    init() {
//        store = TodoDataStore()
        singleRequest = TodoSingleRequest()
        listRequest = TodoListRequest()
    }
}
