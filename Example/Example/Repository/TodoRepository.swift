//
//  TodoRepository.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import Combine
import CoreRepository
import CoreRepositoryRemote

protocol TodoRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<TodoEntity>, Error>
    func create(_ value: TodoEntity, options: FetchOptions?) -> AnyPublisher<TodoEntity, Error>
}

class MockTodoRepository: TodoRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<TodoEntity>, Error> {
        Future { promise in
            let list = (1...20).map {
                TodoEntity(title: "Item \($0)")
            }
            promise(.success(ListDTO(data: list, pagination: nil)))
        }
        .delay(for: 0.2, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func create(_ value: TodoEntity, options: FetchOptions?) -> AnyPublisher<TodoEntity, Error> {
        Future {
            $0(.success(value))
        }
        .delay(for: 0.2, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

class ImplTodoRepository: RemoteIdentifiableSingleRepository, RemoteListRepository {
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
