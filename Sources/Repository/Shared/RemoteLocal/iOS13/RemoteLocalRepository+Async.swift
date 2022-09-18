//
//  RemoteLocalRepository+Async.swift
//  
//
//  Created by Robert on 18/09/2022.
//

import CoreRepository
import CoreRepositoryDataStore
import Foundation

extension RemoteLocalListRepository {
    // swiftlint:disable function_body_length
    @inlinable
    public func getList(options: FetchOptions?) async throws -> ListDTO<T> {
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .`default`:
            guard let cacheOptions = options?.storeFetchOptions else {
                assertionFailure("DataStore options must be set")
                return .init()
            }
            do {
                var list = try await store.getList(options: cacheOptions)
                guard list.data.isEmpty else {
                    return list
                }
                let response = try await listRequest.getList(options: options?.requestOptions)
                list = ListDTO(response: response)
#if !RELEASE && !PRODUCTION
                Swift.print("Get \(list.data.count) items of type \(T.self) from remote successfully!!!")
#endif
                try await store.save(list.data)
                return list
            } catch {
                let response = try await listRequest.getList(options: options?.requestOptions)
                let list = ListDTO(response: response)
#if !RELEASE && !PRODUCTION
                Swift.print("Get \(list.data.count) items of type \(T.self) from remote successfully!!!")
#endif
                try await store.save(list.data)
                return list
            }
        case .forceRefresh(let ignoreDataStoreFailure):
            let response = try await listRequest.getList(options: options?.requestOptions)
            let list = ListDTO(response: response)
#if !RELEASE && !PRODUCTION
            Swift.print("Get \(list.data.count) items of type \(T.self) from remote successfully!!!")
#endif
            if ignoreDataStoreFailure {
                do {
                    try await store.save(list.data)
                    return list
                } catch {
                    return .init()
                }
            } else {
                try await store.save(list.data)
                return list
            }
        case .ignoreDataStore:
            let response = try await listRequest.getList(options: options?.requestOptions)
            let list = ListDTO(response: response)
#if !RELEASE && !PRODUCTION
            Swift.print("Get \(list.data.count) items of type \(T.self) from remote successfully!!!")
#endif
            return list
        }
    }
    // swiftlint:enable function_body_length
}

extension RemoteLocalSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) async throws -> T? {
        guard let result = try await singleRequest.create(value, options: options?.requestOptions).result else {
            return nil
        }
        return try await store.save(result)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) async throws -> T? {
        guard let result = try await singleRequest.update(value, options: options?.requestOptions).result else {
            return nil
        }
        return try await store.save(result)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) async throws {
        try await store.delete(value)
        _ = try await singleRequest.delete(value, options: options?.requestOptions)
    }
}

extension RemoteLocalIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) async throws -> T? {
        let repositoryOptions = options?.repositoryOptions ?? .default
        switch repositoryOptions {
        case .forceRefresh(let ignoreDataStoreFailure):
            guard let item = try await singleRequest.get(id: id, options: options?.requestOptions).result else {
                return nil
            }
            guard ignoreDataStoreFailure else {
                return try await store.save(item)
            }
            _ = try? await self.store.save(item)
            return item
        case .default:
            if let cachedItem = try? await store.get(id, options: options?.storeFetchOptions) {
                return cachedItem
            }
            guard let item = try await singleRequest.get(id: id, options: options?.requestOptions).result else {
                return nil
            }
            return try await self.store.save(item)
        case .ignoreDataStore:
            return try await singleRequest.get(id: id, options: options?.requestOptions).result
        }
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) async throws {
        try await store.delete(id, options: options?.storeFetchOptions)
        _ = try await singleRequest.delete(id: id, options: options?.requestOptions)
    }
}

extension RemoteLocalIdentifiableSingleRepository where T: Expirable {
    @inlinable
    public func refreshIfNeeded(_ list: ListDTO<T>, optionsGenerator: (T.ID) -> FetchOptions?) async throws -> ListDTO<T> {
        if list.data.filter({ !$0.isValid }).isEmpty {
            return list
        }
        var items = list.data
        for (index, item) in items.enumerated() where !item.isValid {
            do {
                if let newItem = try await get(id: item.id, options: optionsGenerator(item.id)) {
                    items[index] = newItem
                }
            } catch { }
        }
        return ListDTO(data: items, pagination: list.pagination)
    }
}
