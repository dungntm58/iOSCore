//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase
import CoreRepository
import CoreRepositoryDataStore

class TodoDataStore: IdentifiableDataStore {
    let ttl: TimeInterval = 60
    var array: [TodoEntity]
    
    func make(total: Int, page: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> Paginated? {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        array = []
    }
    
    func get(_ id: String, options: DataStoreFetchOption?) async throws -> TodoEntity {
        if let value = array.first(where: { $0.id == id }) {
            return value
        }
        throw DataStoreError.notFound
    }
    
    func lastID() async throws -> String {
        if let value = array.last?.id {
            return value
        }
        throw DataStoreError.lookForIDFailure
    }
    
    func save(_ value: TodoEntity) async throws -> TodoEntity {
        if !array.contains(where: { $0.id == value.id }) {
            array.append(value)
        }
        return value
    }
    
    func save(_ values: [TodoEntity]) async throws -> [TodoEntity] {
        array.append(contentsOf: values)
        return values
    }
    
    func erase() async throws {
        array.removeAll()
    }
    
    func getList(options: DataStoreFetchOption) async throws -> ListDTO<TodoEntity> {
        return ListDTO(data: array)
    }
    
    func delete(_ value: TodoEntity) async throws {
        if let index = array.firstIndex(where: { $0.id == value.id }) {
            array.remove(at: index)
        }
    }
    
    func delete(_ values: [TodoEntity]) async throws {
        values.forEach {
            if let index = array.firstIndex(of: $0) {
                array.remove(at: index)
            }
        }
    }
}
