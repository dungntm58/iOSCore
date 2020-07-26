//
//  LocalRepository+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

extension LocalListRepository {
    @inlinable
    public func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        guard let storeFetchOptions = options?.storeFetchOptions else {
            assertionFailure("DataStore options must be set")
            return .error(DataStoreError.storeFailure)
        }
        return store.getListAsync(options: storeFetchOptions)
    }
}

extension LocalSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        store.saveAsync(value)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        store.saveAsync(value)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        store.deleteAsync(value)
    }
}

extension LocalIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) -> Observable<T> {
        store.getAsync(id, options: options?.storeFetchOptions)
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) -> Observable<Void> {
        store.deleteAsync(id, options: options?.storeFetchOptions)
    }
}
