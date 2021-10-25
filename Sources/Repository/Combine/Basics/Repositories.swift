//
//  ModelRepository.swift
//  CoreBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import Combine
import FoundationExtInternal

public protocol SingleModelRepository: ModelRepository {
    func update(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error>
    func create(_ value: T, options: FetchOptions?) -> AnyPublisher<T, Error>
    func delete(_ value: T, options: FetchOptions?) -> AnyPublisher<Void, Error>
}

public protocol ListModelRepository: ModelRepository {
    func getList(options: FetchOptions?) -> AnyPublisher<ListDTO<T>, Error>
}

public protocol IdentifiableSingleRepository: SingleModelRepository where T: Identifiable {
    func get(id: T.ID, options: FetchOptions?) -> AnyPublisher<T, Error>
    func delete(id: T.ID, options: FetchOptions?) -> AnyPublisher<Void, Error>
}
