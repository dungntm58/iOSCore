//
//  DataStore.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 2/15/19.
//

import CoreData
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

public protocol CoreDataDataStore: DataStore {
    var configuration: CoreDataConfiguration { get }
}

public protocol CoreDataIdentifiableDataStore: CoreDataDataStore, IdentifiableDataStore {}
