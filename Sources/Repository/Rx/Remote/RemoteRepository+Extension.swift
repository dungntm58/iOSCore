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
        listRequest
            .getList(options: options?.requestOptions)
            .map(ListDTO.init)
#if !RELEASE && !PRODUCTION
            .do(onNext: {
                Swift.print("Get \($0.data.count) items of type \(T.self) from remote successfully!!!")
            })
#endif
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
            .map { _ in }
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
            .map { _ in }
    }
}
