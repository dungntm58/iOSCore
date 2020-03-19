//
//  DataStore.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 2/15/19.
//

import RealmSwift
import CoreRepository

public protocol RealmDataStore: DataStore {
    var realm: Realm { get }
    var updatePolicy: Realm.UpdatePolicy { get }
}

public protocol RealmIdentifiableDataStore: RealmDataStore, IdentifiableDataStore {}
