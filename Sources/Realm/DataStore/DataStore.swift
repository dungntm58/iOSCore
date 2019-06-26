//
//  DataStore.swift
//  CoreCleanSwiftRealm
//
//  Created by Robert Nguyen on 2/15/19.
//

import RealmSwift
import CoreCleanSwiftBase

public protocol RealmDataStore: DataStore {
    var realm: Realm { get }
}

public protocol RealmIdentifiableDataStore: RealmDataStore, IdentifiableDataStore {}
