//
//  RemoteLocalRepository.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreCleanSwiftBase

public protocol RemoteLocalListRepository: RemoteListRepository, LocalListRepository {}

public protocol RemoteLocalSingleRepository: RemoteSingleRepository, LocalSingleRepository {}

public extension RemoteLocalListRepository {
    func getList(options: DataFetchOptions?) -> Observable<ListResponse<T>> {
        let remote = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map {
                response -> ListResponse<T> in
                #if DEBUG
                let list = response.results!
                Swift.print("Get \(list.count) items of type \(T.self) from remote successfully!!!")
                return ListResponse<T>(data: list, pagination: response.pagination)
                #else
                return ListResponse<T>(data: response.results!, pagination: response.pagination)
                #endif
            }

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                return Observable.error(NSError(domain: "DataStoreError", code: 999, userInfo: [
                    NSLocalizedDescriptionKey: "DataStore options must be set"
                ]))
            }
            let remoteThenDataStore = remote
                .do(onNext: {
                    list in
                    try self.store.saveSync(list.data)
                })
            return store
                .getListAsync(options: cacheOptions)
                .filter { !$0.data.isEmpty }
                .ifEmpty(switchTo: remoteThenDataStore)
        case .forceRefresh(let ignoreFailureDataStore):
            return remote
                .do(onNext: {
                    list in
                    if ignoreFailureDataStore {
                        _ = try? self.store.saveSync(list.data)
                    } else {
                        try self.store.saveSync(list.data)
                    }
                })
        case .ignoreDataStore:
            return remote
        }
    }
}

public extension RemoteLocalSingleRepository {
    func create(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return singleRequest
            .create(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
            .map(store.saveSync)
    }

    func update(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return singleRequest
            .update(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
            .map(store.saveSync)
    }

    func delete(_ value: T, options: DataFetchOptions?) -> Observable<Bool> {
        let cacheObservable = store.deleteAsync(value)
        let remote = singleRequest.delete(value, options: options?.requestOptions)

        return .zip(remote, cacheObservable) { _, cache in cache }
    }
}

public protocol RemoteLocalIdentifiableSingleRepository: RemoteLocalSingleRepository, RemoteIdentifiableSingleRepository, LocalIdentifiableSingleRepository {}

public extension RemoteLocalIdentifiableSingleRepository {
    func get(id: T.IDType, options: DataFetchOptions?) -> Observable<T> {
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreFailureDataStore):
            if ignoreFailureDataStore {
                return remote
                    .do (onNext: {
                        value in
                        _ = try? self.store.saveSync(value)
                    })
            }
            return remote.map(store.saveSync)
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return .first(cacheObservable, remote)
        case .ignoreDataStore:
            return remote
        }
    }

    func delete(id: T.IDType, options: DataFetchOptions?) -> Observable<Bool> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)

        return .zip(remote, cacheObservable) { _, cache in cache }
    }
}

public extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    func refreshIfNeeded(_ list: ListResponse<T>, optionsGenerator: (T.IDType) -> DataFetchOptions?) -> Observable<ListResponse<T>> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return .from(optional: list)
        }
        let pagination = list.pagination
        let singleObservables = list.data.map {
            item -> Observable<T> in
            if item.isValid {
                return .from(optional: item)
            } else {
                return self.get(id: item.id, options: optionsGenerator(item.id))
            }
        }
        return Observable.concat(singleObservables)
            .toArray()
            .map { ListResponse<T>(data: $0, pagination: pagination) }
            .asObservable()
    }
}
