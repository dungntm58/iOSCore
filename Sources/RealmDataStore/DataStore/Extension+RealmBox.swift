//
//  Extension+RealmBox.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreRepository

public extension RealmDataStore where T: RealmObjectBox {
    @discardableResult
    func saveSync(_ value: T) throws -> T {
        let realm = try Realm()
        try Helper.instance.saveSync(value.core, ttl: ttl, realm: realm, update: self.updatePolicy)
        return value
    }

    @discardableResult
    func saveSync(_ values: [T]) throws -> [T] {
        let realm = try Realm()
        try Helper.instance.saveSync(values.map(\.core), ttl: ttl, realm: realm, update: self.updatePolicy)
        return values
    }

    func deleteSync(_ value: T) throws {
        let realm = try Realm()
        try Helper.instance.deleteSync(value.core, realm: realm)
    }

    func getList(options: DataStoreFetchOption) throws -> ListDTO<T> {
        let realm = try Realm()
        let listResult = try Helper.instance.getList(of: T.RealmObject.self, options: options, ttl: ttl, realm: realm)

        let before = listResult.previous.map(T.init)
        let after = listResult.next.map(T.init)
        let pagination = make(total: listResult.total, size: listResult.size, previous: before, next: after)
        return .init(data: listResult.items.map(T.init), pagination: pagination)
    }

    func eraseSync() throws {
        let realm = try Realm()
        try Helper.instance.eraseSync(of: T.RealmObject.self, realm: realm)
    }
}

public extension RealmIdentifiableDataStore where T: RealmObjectBox {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T {
        let realm = try Realm()
        guard let value = realm.object(ofType: T.RealmObject.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }
        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }
        return T(core: value)
    }

    func lastID() throws -> T.ID {
        let realm = try Realm()
        if let value = realm.objects(T.RealmObject.self).last {
            return T(core: value).id
        }
        throw DataStoreError.lookForIDFailure
    }
}
