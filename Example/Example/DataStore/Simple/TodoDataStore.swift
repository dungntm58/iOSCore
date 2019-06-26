//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase

class TodoDataStore: IdentifiableDataStore {
    let ttl: TimeInterval = 60
    var array: [TodoEntity]
    
    func make(total: Int, size: Int, before: TodoEntity?, after: TodoEntity?) -> PaginationResponse {
        return AppPaginationResponse(total: total, pageSize: size, after: after?.id as Any, before: before?.id as Any)
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
    
    func eraseSync() throws -> Bool {
        array.removeAll()
        return true
    }
    
    func getList(options: DataStoreFetchOption) throws -> ListResponse<TodoEntity> {
        return ListResponse(data: array)
    }
    
    func deleteSync(_ value: TodoEntity) throws -> Bool {
        if let index = array.firstIndex(where: { $0.id == value.id }) {
            array.remove(at: index)
        }
        return true
    }
}
