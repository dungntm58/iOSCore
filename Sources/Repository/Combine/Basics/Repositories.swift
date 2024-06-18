//
//  ModelRepository.swift
//  CoreBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import Combine

public protocol SingleModelRepository<T>: ModelRepository {
    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error>
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error>
    func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error>
}

public protocol ListModelRepository<T>: ModelRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error>
}

public protocol IdentifiableSingleRepository<T>: SingleModelRepository where T: Identifiable {
    func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error>
    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error>
}
