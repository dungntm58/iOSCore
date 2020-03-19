//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreRepository

class UserDataStore: IdentifiableDataStore {
    let userDefaults: UserDefaults
    
    func make(total: Int, size: Int, previous: UserEntity?, next: UserEntity?) -> PaginationDTO {
        AppPaginationDTO(total: total, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        userDefaults = .standard
    }
    
    func getSync(_ id: String, options: DataStoreFetchOption?) throws -> UserEntity {
        if let data = userDefaults.data(forKey: id) {
            return try Constant.Request.jsonDecoder.decode(UserEntity.self, from: data)
        }
        throw DataStoreError.notFound
    }
    
    func lastID() throws -> String {
        throw DataStoreError.notFound
    }
    
    func saveSync(_ value: UserEntity) throws -> UserEntity {
        let data = try JSONEncoder().encode(value)
        userDefaults.set(data, forKey: value.id)
        return value
    }
    
    func saveSync(_ values: [UserEntity]) throws -> [UserEntity] {
        throw DataStoreError.unknown
    }
    
    func eraseSync() throws {
    }
    
    func getList(options: DataStoreFetchOption) throws -> ListDTO<UserEntity> {
        ListDTO(data: [])
    }
    
    func deleteSync(_ value: UserEntity) throws {
        userDefaults.set(nil, forKey: value.id)
    }
}
