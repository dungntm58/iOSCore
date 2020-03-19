//
//  LocalRepository+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Combine

public extension LocalListRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            assertionFailure("DataStore options must be set")
            return Empty().eraseToAnyPublisher()
        }
        return store.getListAsync(options: storeFetchOptions)
    }
}

public extension LocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.saveAsync(value)
    }

    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.saveAsync(value)
    }

    func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        store.deleteAsync(value)
    }
}

public extension LocalIdentifiableSingleRepository {
    func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error> {
        store.getAsync(id, options: options?.storeFetchOptions)
    }

    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        store.deleteAsync(id, options: options?.storeFetchOptions)
    }
}
