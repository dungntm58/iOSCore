//
//  RemoteLocalRepository+Extension.swift
//  CoreRemoteRepository
//
//  Created by Robert on 8/10/19.
//

import Combine

public extension RemoteLocalListRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        #if !RELEASE && !PRODUCTION
        let remote = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map(ListDTO.init)
            .handleEvents(receiveOutput: {
                Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
            })
        #else
        let remote = listRequest
            .getList(options: options?.requestOptions)
            .filter { $0.results != nil }
            .map(ListDTO.init)
        #endif
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .default:
            guard let cacheOptions = options?.storeFetchOptions else {
                assertionFailure("DataStore options must be set")
                return Empty().eraseToAnyPublisher()
            }
            let remoteThenDataStore = remote
                .tryMap {
                    list -> ListDTO<T> in
                    try self.store.saveSync(list.data)
                    return list
                }
                .eraseToAnyPublisher()
            return store
                .getListAsync(options: cacheOptions)
                .catch { _ in remoteThenDataStore }
                .flatMap {
                    list -> AnyPublisher<ListDTO<T>, Error> in
                    if list.data.isEmpty {
                        return remoteThenDataStore
                    } else {
                        return Future<ListDTO<T>, Error> {
                            promise in
                            promise(.success(list))
                        }.eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        case .forceRefresh(let ignoreDataStoreFailure):
            return remote
                .tryCompactMap({
                    list -> ListDTO<T> in
                    if ignoreDataStoreFailure {
                        _ = try? self.store.saveSync(list.data)
                    } else {
                        try self.store.saveSync(list.data)
                    }
                    return list
                })
                .eraseToAnyPublisher()
        case .ignoreDataStore:
            return remote.eraseToAnyPublisher()
        }
    }
}

public extension RemoteLocalSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
            .tryMap(store.saveSync)
            .eraseToAnyPublisher()
    }

    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
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
            .compactMap(\.result)

        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard ignoreDataStoreFailure else {
                return remote.tryMap(store.saveSync).eraseToAnyPublisher()
            }
            return remote
                .handleEvents(receiveOutput: {
                    _ = try? self.store.saveSync($0)
                })
                .eraseToAnyPublisher()
        case .default:
            let cacheObservable = store.getAsync(id, options: options?.storeFetchOptions)
            return cacheObservable.catch { _ in remote}.eraseToAnyPublisher()
        case .ignoreDataStore:
            return remote.eraseToAnyPublisher()
        }
    }

    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        let cacheObservable = store.deleteAsync(id, options: options?.storeFetchOptions)
        let remote = singleRequest.delete(id: id, options: options?.requestOptions)
        return remote.zip(cacheObservable) { _, _ in () }.eraseToAnyPublisher()
    }
}

public extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.ID) -> FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return Future<ListDTO<T>, Error> { $0(.success(list)) }
                .eraseToAnyPublisher()
        }
        let singlePublishers = list.data
            .map ({
                item -> AnyPublisher<T, Error> in
                if item.isValid {
                    return Future<T, Error> { $0(.success(item)) }
                        .eraseToAnyPublisher()
                } else {
                    return self.get(id: item.id, options: optionsGenerator(item.id))
                }
            })
        let mergePublishers = Publishers.MergeMany(singlePublishers).collect()
        return Publishers.Zip3(
            Future<PaginationDTO?, Error> { $0(.success(list.pagination)) },
            Future<[T.ID], Error> { $0(.success(list.data.map(\.id))) },
            mergePublishers
        ).map {
            pagination, ids, arr in
            ListDTO<T>(
                data: ids.compactMap { id in arr.first(where: { $0.id == id }) },
                pagination: pagination
            )
        }
        .eraseToAnyPublisher()
    }
}
