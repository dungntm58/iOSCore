//
//  LocalRepository+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension LocalListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            assertionFailure("DataStore options must be set")
            return .error(DataStoreError.storeFailure)
        }
        return store.getListAsync(options: storeFetchOptions)
    }
}

public extension LocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        store.saveAsync(value)
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        store.saveAsync(value)
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        store.deleteAsync(value)
    }
}

public extension LocalIdentifiableSingleRepository {
    func get(id: T.ID, options: FetchOptions?) -> Observable<T> {
        store.getAsync(id, options: options?.storeFetchOptions)
    }

    func delete(id: T.ID, options: FetchOptions?) -> Observable<Void> {
        store.deleteAsync(id, options: options?.storeFetchOptions)
    }
}
