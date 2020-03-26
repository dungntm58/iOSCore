//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import Combine

public extension RemoteListRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error> {
        let remote = listRequest
            .getList(options: options?.requestOptions)
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
        return remote.handleEvents(receiveOutput: {
            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
        }).eraseToAnyPublisher()
        #else
        return remote.eraseToAnyPublisher()
        #endif
    }
}

public extension RemoteSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        singleRequest
            .delete(value, options: options?.requestOptions)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

public extension RemoteIdentifiableSingleRepository {
    func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error> {
        singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)
            .eraseToAnyPublisher()
    }

    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error> {
        singleRequest
            .delete(id: id, options: options?.requestOptions)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
