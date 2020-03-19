//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreRepository

class TodoDataStore: IdentifiableDataStore {
    let ttl: TimeInterval = 60
    var array: [TodoEntity]
    
    func make(total: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> PaginationDTO {
        AppPaginationDTO(total: total, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        array = []
    }
    
    func getSync(_ id: String, options: DataStoreFetchOption?) throws -> TodoEntity {
        if let value = array.first(where: { $0.id == id }) {
            return value
        }
        throw DataStoreError.notFound
    }
    
    func lastID() throws -> String {
        if let value = array.last?.id {
            return value
        }
        throw DataStoreError.lookForIDFailure
    }
    
    func saveSync(_ value: TodoEntity) throws -> TodoEntity {
        if !array.contains(where: { $0.id == value.id }) {
            array.append(value)
        }
        return value
    }
    
    func saveSync(_ values: [TodoEntity]) throws -> [TodoEntity] {
        array.append(contentsOf: values)
        return values
    }
    
    func eraseSync() throws {
        array.removeAll()
    }
    
    func getList(options: DataStoreFetchOption) throws -> ListDTO<TodoEntity> {
        return ListDTO(data: array)
    }
    
    func deleteSync(_ value: TodoEntity) throws {
        if let index = array.firstIndex(where: { $0.id == value.id }) {
            array.remove(at: index)
        }
    }
}
