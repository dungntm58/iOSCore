//
//  DataStore.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 2/15/19.
//

import RealmSwift
import CoreRepository

public protocol RealmDataStore: DataStore {
    var updatePolicy: Realm.UpdatePolicy { get }
    func getRealm() throws -> Realm
}

extension RealmDataStore {
    @inlinable
    public func getRealm() throws -> Realm {
        try threadSharedRealm()
    }
}

public protocol RealmIdentifiableDataStore: RealmDataStore, IdentifiableDataStore {}
