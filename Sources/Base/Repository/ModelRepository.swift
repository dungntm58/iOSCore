//
//  ModelRepository.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import RxSwift

public protocol ModelRepository {
    associatedtype T
}

public protocol SingleModelRepository: ModelRepository {
    func update(_ value: T, options: DataFetchOptions?) -> Observable<T>
    func create(_ value: T, options: DataFetchOptions?) -> Observable<T>
    func delete(_ value: T, options: DataFetchOptions?) -> Observable<Bool>
}

public protocol ListModelRepository: ModelRepository {
    func getList(options: DataFetchOptions?) -> Observable<ListResponse<T>>
}

public protocol IdentifiableSingleRepository: SingleModelRepository where T: Identifiable {
    func get(id: T.IDType, options: DataFetchOptions?) -> Observable<T>
    func delete(id: T.IDType, options: DataFetchOptions?) -> Observable<Bool>
}
