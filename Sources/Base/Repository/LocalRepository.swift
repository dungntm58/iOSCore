//
//  LocalRepository.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

public protocol LocalRepository: ModelRepository where T == DS.T {
    associatedtype DS: DataStore

    var store: DS { get }
}

public protocol LocalListRepository: LocalRepository, ListModelRepository {}

public protocol LocalSingleRepository: LocalRepository, SingleModelRepository {}

public extension LocalListRepository {
    func getList(options: DataFetchOptions?) -> Observable<ListResponse<T>> {
        if let storeFetchOptions = options?.storeFetchOptions {
            return store.getListAsync(options: storeFetchOptions)
        }

        return .error(NSError(domain: "DataStoreError", code: 999, userInfo: [
            NSLocalizedDescriptionKey: "DataStore options must be set"
        ]))
    }
}

public extension LocalSingleRepository {
    func create(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return store.saveAsync(value)
    }

    func update(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return store.saveAsync(value)
    }

    func delete(_ value: T, options: DataFetchOptions?) -> Observable<Bool> {
        return store.deleteAsync(value)
    }
}

public protocol LocalIdentifiableSingleRepository: IdentifiableSingleRepository, LocalSingleRepository where DS: IdentifiableDataStore {}

public extension LocalIdentifiableSingleRepository {
    func get(id: T.IDType, options: DataFetchOptions?) -> Observable<T> {
        return store.getAsync(id, options: options?.storeFetchOptions)
    }

    func delete(id: T.IDType, options: DataFetchOptions?) -> Observable<Bool> {
        return store.deleteAsync(id, options: options?.storeFetchOptions)
    }
}
