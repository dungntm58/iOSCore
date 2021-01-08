//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

extension RemoteListRepository {
    @inlinable
    public func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
        var remote: Observable<ListDTO<T>> = listRequest
            .getList(options: options?.requestOptions)
            .map(ListDTO.init)
        #if !RELEASE && !PRODUCTION
        remote = remote.do(onNext: {
            Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
        })
        #endif
        return remote
    }
}

extension RemoteSingleRepository {
    @inlinable
    public func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
    }

    @inlinable
    public func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
    }

    @inlinable
    public func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(value, options: options?.requestOptions)
            .mapToVoid()
    }
}

extension RemoteIdentifiableSingleRepository {
    @inlinable
    public func get(id: T.ID, options: FetchOptions?) -> Observable<T> {
        singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)
    }

    @inlinable
    public func delete(id: T.ID, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(id: id, options: options?.requestOptions)
            .mapToVoid()
    }
}
