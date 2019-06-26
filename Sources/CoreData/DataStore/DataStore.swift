//
//  DataStore.swift
//  CoreCleanSwiftCoreData
//
//  Created by Robert Nguyen on 2/15/19.
//

import CoreData
import CoreCleanSwiftBase

public protocol CoreDataDataStore: DataStore {
    var configuration: CoreDataConfiguration { get }
}

public protocol CoreDataIdentifiableDataStore: CoreDataDataStore, IdentifiableDataStore {}
