//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase
import CoreRepository
import CoreRepositoryDataStore

class UserDataStore: IdentifiableDataStore {
    let userDefaults: UserDefaults
    
    func make(total: Int, page: Int, size: Int, previous: UserEntity?, next: UserEntity?) -> Paginated? {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        userDefaults = .standard
    }
    
    func get(_ id: String, options: DataStoreFetchOption?) async throws -> UserEntity {
        if let data = userDefaults.data(forKey: id) {
            return try Constant.Request.jsonDecoder.decode(UserEntity.self, from: data)
        }
        throw DataStoreError.notFound
    }
    
    func lastID() async throws -> String {
        throw DataStoreError.notFound
    }
    
    func save(_ value: UserEntity) async throws -> UserEntity {
        let data = try JSONEncoder().encode(value)
        userDefaults.set(data, forKey: value.id)
        return value
    }
    
    func save(_ values: [UserEntity]) async throws -> [UserEntity] {
        throw DataStoreError.unknown
    }
    
    func erase() async throws {
    }
    
    func getList(options: DataStoreFetchOption) async throws -> ListDTO<UserEntity> {
        ListDTO(data: [])
    }
    
    func delete(_ value: UserEntity) async throws {
        userDefaults.set(nil, forKey: value.id)
    }
    
    func delete(_ values: [UserEntity]) async throws {
        values.forEach {
            userDefaults.setValue(nil, forKey: $0.id)
        }
    }
    
    func delete(_ id: String, options: CoreRepository.DataStoreFetchOption?) async throws {
        
    }
}
