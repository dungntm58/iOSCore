//
//  LocalRepository+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Combine
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

extension LocalListRepository {
    @inlinable
    public func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            assertionFailure("DataStore options must be set")
            return Empty().eraseToAnyPublisher()
        }
        return store.getList(options: storeFetchOptions)
    }
}

extension LocalSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.save(value)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.save(value)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        store.delete(value)
    }
}

extension LocalIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.get(id, options: options?.storeFetchOptions)
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        store.delete(id, options: options?.storeFetchOptions)
    }
}
