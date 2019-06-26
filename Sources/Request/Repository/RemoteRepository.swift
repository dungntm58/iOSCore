//
//  RemoteRepository.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreCleanSwiftBase

public protocol RemoteListRepository: ListModelRepository  where ListRequest.Response.ValueType == T {
    associatedtype ListRequest: ListModelHTTPRequest

    var listRequest: ListRequest { get }
}

public protocol RemoteSingleRepository: SingleModelRepository where SingleRequest.Response.ValueType == T {
    associatedtype SingleRequest: SingleModelHTTPRequest

    var singleRequest: SingleRequest { get }
}

public extension RemoteListRepository {
    func getList(options: DataFetchOptions?) -> Observable<ListResponse<T>> {
        return listRequest
            .getList(options: options?.requestOptions)
            .map {
                response -> ListResponse<T> in
                #if DEBUG
                let list = response.results!
                Swift.print("Get \(list.count) items of type \(T.self) from remote successfully!!!")
                return ListResponse<T>(data: list, pagination: response.pagination)
                #else
                return ListResponse<T>(data: response.results!, pagination: response.pagination)
                #endif
        }
    }
}

public extension RemoteSingleRepository {
    func create(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return singleRequest
            .create(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func update(_ value: T, options: DataFetchOptions?) -> Observable<T> {
        return singleRequest
            .update(value, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func delete(_ value: T, options: DataFetchOptions?) -> Observable<Bool> {
        return singleRequest
            .delete(value, options: options?.requestOptions)
            .map { _ in true }
    }
}

public protocol RemoteIdentifiableSingleRepository: RemoteSingleRepository, IdentifiableSingleRepository where SingleRequest: IdentifiableHTTPRequest {}

public extension RemoteIdentifiableSingleRepository {
    func get(id: T.IDType, options: DataFetchOptions?) -> Observable<T> {
        return singleRequest
            .get(id: id, options: options?.requestOptions)
            .flatMap { Observable.from(optional: $0.result) }
    }

    func delete(id: T.IDType, options: DataFetchOptions?) -> Observable<Bool> {
        return singleRequest
            .delete(id: id, options: options?.requestOptions)
            .map { _ in true }
    }
}
