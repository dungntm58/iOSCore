//
//  RemoteLocalRepository+Extension.swift
//  CoreRemoteRepository
//
//  Created by Robert on 8/10/19.
//

import Combine

public extension RemoteLocalListRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        var remote = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
//        remote = remote.do(onNext: {
//            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
//        })
        #endif
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                assertionFailure("DataStore options must be set")
                return Empty().eraseToAnyPublisher()
            }
            let remoteThenDataStore = remote
                .breakpoint(receiveOutput: {
                    try self.store.saveSync($0.data)
                    return true
                })
            return store
                .getListAsync(options: cacheOptions)
                .catchError { _ in remoteThenDataStore }
                .filter { !$0.data.isEmpty }
                .ifEmpty(switchTo: remoteThenDataStore)
        case .forceRefresh(let ignoreDataStoreFailure):
            return remote
                .breakpoint(receiveOutput: {
                    list in
                    if ignoreDataStoreFailure {
                        _ = try? self.store.saveSync(list.data)
                    } else {
                        try self.store.saveSync(list.data)
                    }
                    return true
                })
        case .ignoreDataStore:
            return remote.eraseToAnyPublisher()
        }
    }
}

public extension RemoteLocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap { $0.result }
            .tryMap(store.saveSync)
            .eraseToAnyPublisher()
    }

    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap { $0.result }
            .tryMap(store.saveSync)
            .eraseToAnyPublisher()
    }

    func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        let cacheObservable = store.deleteAsync(value)
        let remote = singleRequest.delete(value, options: options?.requestOptions)
        return remote
            .zip(cacheObservable) { _,_ in () }
            .eraseToAnyPublisher()
    }
}

public extension RemoteLocalIdentifiableSingleRepository {
    func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error> {
        let remote = singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap { $0.result }

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard ignoreDataStoreFailure else {
                return remote.tryMap(store.saveSync).eraseToAnyPublisher()
            }
            return remote
                .do(onNext: { _ = try? self.store.saveSync($0) })
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return .first(cacheObservable, remote)
        case .ignoreDataStore:
            return remote.eraseToAnyPublisher()
        }
    }

    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)
        return remote.zip(cacheObservable) { _, _ in () }
    }
}

public extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.ID) -> FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return .from(optional: list)
        }
        let pagination = list.pagination
        let singleObservables = list.data.map {
            item -> AnyPublisher<T, Error> in
            if item.isValid {
                return .from(optional: item)
            } else {
                return self.get(id: item.id, options: optionsGenerator(item.id))
            }
        }
        return Observable.concat(singleObservables)
            .toArray()
            .map { ListDTO<T>(data: $0, pagination: pagination) }
            .asObservable()
    }
}
