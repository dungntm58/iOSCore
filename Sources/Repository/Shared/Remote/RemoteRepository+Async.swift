//
//  RemoteRepository+Async.swift
//  iOSCore
//
//  Created by Robert on 18/09/2022.
//

import CoreRepository
#if canImport(CoreRepositoryRequest)
import CoreRepositoryRequest
#endif

extension RemoteListRepository {
    @inlinable
    public func getList(options: FetchOptions?) async throws -> ListDTO<T> {
        let response = try await listRequest.getList(options: options?.requestOptions)
        let list = ListDTO(response: response)
#if !RELEASE && !PRODUCTION
        Swift.print("Get \(list.data.count) items of type \(T.self) from remote successfully!!!")
#endif
        return list
    }
}

extension RemoteSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) async throws -> T? {
        try await singleRequest.create(value, options: options?.requestOptions).result
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) async throws -> T? {
        try await singleRequest.update(value, options: options?.requestOptions).result
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) async throws {
        _ = try await singleRequest.delete(value, options: options?.requestOptions)
    }
}

extension RemoteIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) async throws -> T? {
        try await singleRequest.get(id: id, options: options?.requestOptions).result
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) async throws {
        _ = try await singleRequest.delete(id: id, options: options?.requestOptions)
    }
}
