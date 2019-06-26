//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase

class UserDataStore: IdentifiableDataStore {
    let userDefaults: UserDefaults
    
    func make(total: Int, size: Int, before: UserEntity?, after: UserEntity?) -> PaginationResponse {
        return AppPaginationResponse(total: total, pageSize: size, after: after?.id as Any, before: before?.id as Any)
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
    
    func eraseSync() throws -> Bool {
        return true
    }
    
    func getList(options: DataStoreFetchOption) throws -> ListResponse<UserEntity> {
        return ListResponse(data: [])
    }
    
    func deleteSync(_ value: UserEntity) throws -> Bool {
        userDefaults.set(nil, forKey: value.id)
        return true
    }
}
