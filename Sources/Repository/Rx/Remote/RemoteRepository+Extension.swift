//
//  RemoteRepository+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension RemoteListRepository {
    func getList(options: FetchOptions?) -> Observable<ListDTO<T>> {
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

public extension RemoteSingleRepository {
    func create(_ value: T, options: FetchOptions?) -> Observable<T> {
        #if swift(>=5.2)
        return singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap(\.result)
        #else
        return singleRequest
            .create(value, options: options?.requestOptions)
            .compactMap { $0.result }
        #endif
    }

    func update(_ value: T, options: FetchOptions?) -> Observable<T> {
        #if swift(>=5.2)
        return singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap(\.result)
        #else
        return singleRequest
            .update(value, options: options?.requestOptions)
            .compactMap { $0.result }
        #endif
    }

    func delete(_ value: T, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(value, options: options?.requestOptions)
            .mapToVoid()
    }
}

public extension RemoteIdentifiableSingleRepository {
    func get(id: T.ID, options: FetchOptions?) -> Observable<T> {
        #if swift(>=5.2)
        return singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap(\.result)
        #else
        return singleRequest
            .get(id: id, options: options?.requestOptions)
            .compactMap { $0.result }
        #endif
        
    }

    func delete(id: T.ID, options: FetchOptions?) -> Observable<Void> {
        singleRequest
            .delete(id: id, options: options?.requestOptions)
            .mapToVoid()
    }
}
