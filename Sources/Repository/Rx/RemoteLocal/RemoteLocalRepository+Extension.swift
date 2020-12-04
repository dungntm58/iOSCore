//
//  RemoteLocalRepository+Extension.swift
//  CoreRemoteRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

extension RemoteLocalListRepository {
    @inlinable
    public func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        var remote: Observable<ListDTO<T>> = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
        remote = remote.do(onNext: {
            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
        })
        #endif
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                assertionFailure("DataStore options must be set")
                return .error(DataStoreError.storeFailure)
            }
            let remoteThenDataStore = remote
                .do(onNext: { try self.store.saveSync($0.data) })
            return store
                .getListAsync(options: cacheOptions)
                .catchError { _ in remoteThenDataStore }
                .filter { !$0.data.isEmpty }
                .ifEmpty(switchTo: remoteThenDataStore)
        case .forceRefresh(let ignoreDataStoreFailure):
            return remote
                .do(onNext: {
                    list in
                    if ignoreDataStoreFailure {
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

extension RemoteLocalSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
            .map(store.saveSync)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
            .map(store.saveSync)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        let cacheObservable = store.deleteAsync(value)
        let remote = singleRequest.delete(value, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _,_ in }
    }
}

extension RemoteLocalIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) -> Observable<T> {
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard ignoreDataStoreFailure else {
                return remote.map(store.saveSync)
            }
            return remote
                .do(onNext: { _ = try? self.store.saveSync($0) })
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return .first(cacheObservable, remote)
        case .ignoreDataStore:
            return remote
        }
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) -> Observable<Void> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)
        return .zip(remote, cacheObservable) { _, _ in }
    }
}

extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    @inlinable
    public func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.ID) -> FetchOptions?) -> Observable<ListDTO<T>> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return .from(optional: list)
        }
        let singleObservables = list.data.map {
            item -> Observable<T> in
            if item.isValid {
                return .from(optional: item)
            } else {
                return self.get(id: item.id, options: optionsGenerator(item.id))
            }
        }
        let idsObservable = Observable.deferred { .just(list.data.map(\.id )) }
        return .zip(
            Observable.just(list.pagination),
            idsObservable,
            Observable.merge(singleObservables)
                .toArray()
                .asObservable()
        ) {
            pagination, ids, arr in
            ListDTO<T>(
                data: ids.compactMap { id in arr.first(where: { $0.id == id }) },
                pagination: pagination
            )
        }
    }
}
