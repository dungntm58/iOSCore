//
//  LocalRepository+Async.swift
//  iOSCore
//
//  Created by Robert on 18/09/2022.
//

import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

extension LocalListRepository {
    @inlinable
    public func getList(options: FetchOptions?) async throws -> ListDTO<T> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            assertionFailure("DataStore options must be set")
            return .init()
        }
        return try await store.getList(options: storeFetchOptions)
    }
}

extension LocalSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) async throws -> T {
        try await store.save(value)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) async throws -> T {
        try await store.save(value)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) async throws {
        try await store.delete(value)
    }
}

extension LocalIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) async throws -> T {
        try await store.get(id, options: options?.storeFetchOptions)
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) async throws {
        try await store.delete(id, options: options?.storeFetchOptions)
    }
}
