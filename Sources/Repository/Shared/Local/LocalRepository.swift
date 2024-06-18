//
//  LocalRepository.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

public protocol LocalRepository<T>: ModelRepository where T == Store.T {
    associatedtype Store: DataStore

    var store: Store { get }
}

public protocol LocalListRepository<T>: LocalRepository, ListModelRepository {}

public protocol LocalSingleRepository<T>: LocalRepository, SingleModelRepository {}

public protocol LocalIdentifiableSingleRepository<T>: IdentifiableSingleRepository, LocalSingleRepository where Store: IdentifiableDataStore {}
