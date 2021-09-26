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

public protocol LocalRepository: ModelRepository where T == Store.T {
    associatedtype Store: DataStore

    var store: Store { get }
}

public protocol LocalListRepository: LocalRepository, ListModelRepository {}

public protocol LocalSingleRepository: LocalRepository, SingleModelRepository {}

public protocol LocalIdentifiableSingleRepository: IdentifiableSingleRepository, LocalSingleRepository where Store: IdentifiableDataStore {}
