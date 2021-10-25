//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import Combine

extension RemoteListRepository {
    @inlinable
    public func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        listRequest
            .getList(options: options?.requestOptions)
            .map(ListDTO.init)
#if !RELEASE && !PRODUCTION
            .handleEvents(receiveOutput: {
                Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
            })
#endif
            .eraseToAnyPublisher()
    }
}

extension RemoteSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        singleRequest
            .delete(value, options: options?.requestOptions)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

extension RemoteIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        singleRequest
            .delete(id: id, options: options?.requestOptions)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
